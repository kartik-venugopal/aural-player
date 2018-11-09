import Cocoa
import AVFoundation

/*
    Wrapper around AVAudioEngine. Manages the AVAudioEngine audio graph.
 */
class AudioGraph: AudioGraphProtocol, PlayerGraphProtocol, RecorderGraphProtocol, PersistentModelObject {
    
    private let audioEngine: AVAudioEngine
    private let mainMixer: AVAudioMixerNode
    
    // Audio graph nodes
    var eqUnit: EQUnit
    var pitchUnit: PitchUnit
    var timeUnit: TimeUnit
    var reverbUnit: ReverbUnit
    
    // Playback
    internal let playerNode: AVAudioPlayerNode
    
    // Effects
    private let filterNode: FlexibleFilterNode
    private let delayNode: AVAudioUnitDelay
    
    private let auxMixer: AVAudioMixerNode  // Used for conversions of sample rates / channel counts
    
    // Helper
    private let audioEngineHelper: AudioEngineHelper
    
    internal let nodeForRecorderTap: AVAudioNode
    
    // Temp variables to store individual node bypass states that can be saved/restored when master bypass is toggled
    private var masterBypass: Bool
    
    private var delaySuppressed: Bool
    private var filterSuppressed: Bool
    
    // Sound setting value holders
    private var playerVolume: Float
    private var muted: Bool
    
    // Presets
    private(set) var masterPresets: MasterPresets = MasterPresets()
    private(set) var delayPresets: DelayPresets = DelayPresets()
    private(set) var filterPresets: FilterPresets = FilterPresets()
    
    // Sets up the audio engine
    init(_ state: AudioGraphState) {
        
        playerNode = AVAudioPlayerNode()
        
        audioEngine = AVAudioEngine()
        mainMixer = audioEngine.mainMixerNode
        
        eqUnit = EQUnit(state)
        pitchUnit = PitchUnit(state)
        timeUnit = TimeUnit(state)
        reverbUnit = ReverbUnit(state)
        
        delayNode = AVAudioUnitDelay()
        filterNode = FlexibleFilterNode()
        auxMixer = AVAudioMixerNode()
        nodeForRecorderTap = mainMixer
        
        audioEngineHelper = AudioEngineHelper(engine: audioEngine)
        
        var nodes = [playerNode, auxMixer]
        nodes.append(contentsOf: eqUnit.avNodes)
        nodes.append(contentsOf: pitchUnit.avNodes)
        nodes.append(contentsOf: timeUnit.avNodes)
        nodes.append(contentsOf: reverbUnit.avNodes)
        nodes.append(contentsOf: [filterNode, delayNode])
        audioEngineHelper.addNodes(nodes)
        
        audioEngineHelper.connectNodes()
        audioEngineHelper.prepareAndStart()
        
        muted = state.muted
        playerVolume = state.volume
        
        if (muted) {
            playerNode.volume = 0
        } else {
            playerNode.volume = playerVolume
        }
        
        playerNode.pan = state.balance
        
        masterBypass = state.masterState != .active
        masterPresets.addPresets(state.masterUserPresets)
        
        // Delay
        delayNode.bypass = state.delayState != .active
        delaySuppressed = state.delayState == .suppressed
        delayNode.wetDryMix = state.delayAmount
        delayNode.delayTime = state.delayTime
        delayNode.feedback = state.delayFeedback
        delayNode.lowPassCutoff = state.delayLowPassCutoff
        delayPresets.addPresets(state.delayUserPresets)
        
        // Filter
        filterNode.bypass = state.filterState != .active
        filterSuppressed = state.filterState == .suppressed
        filterNode.addBands(state.filterBands)
        filterPresets.addPresets(state.filterUserPresets)
    }

    private func bypassAllUnits() {
        [delayNode, filterNode].forEach({$0.bypass = true})
    }
    
    func reconnectPlayerNodeWithFormat(_ format: AVAudioFormat) {
        audioEngineHelper.reconnectNodes(playerNode, outputNode: auxMixer, format: format)
    }
    
    func toggleMasterBypass() -> Bool {
        
        let newState = !masterBypass
        masterBypass = newState
     
        if masterBypass {
            
            // Active -> Inactive
            
            // If a unit was active (i.e. not bypassed), mark it as now being suppressed by the master bypass
            
            [eqUnit, pitchUnit, timeUnit, reverbUnit].forEach({$0.suppress()})
            
            delaySuppressed = !delayNode.bypass
            filterSuppressed = !filterNode.bypass
            
            bypassAllUnits()
            
        } else {
            
            // Inactive -> Active
            
            [eqUnit, pitchUnit, timeUnit, reverbUnit].forEach({$0.unsuppress()})
            
            delayNode.bypass = !delaySuppressed
            filterNode.bypass = !filterSuppressed
        }
        
        return newState
    }
    
    func isMasterBypass() -> Bool {
        return masterBypass
    }
    
    func saveMasterPreset(_ presetName: String) {
        
        let dummyPresetName = "masterPreset_" + presetName

        // EQ state
        let eqState = eqUnit.state
        let eqBands = eqUnit.bands
        let eqGlobalGain = eqUnit.globalGain

        let eqPreset = EQPreset(dummyPresetName, eqState, eqBands, eqGlobalGain, false)

        // Pitch state
        let pitchState = pitchUnit.state
        let pitch = pitchUnit.pitch
        let pitchOverlap = pitchUnit.overlap
        
        let pitchPreset = PitchPreset(dummyPresetName, pitchState, pitch, pitchOverlap, false)

        // Time state
        let timeState = timeUnit.state
        let rate = timeUnit.rate
        let timeOverlap = timeUnit.overlap
        let timePitchShift = timeUnit.shiftPitch

        let timePreset = TimePreset(dummyPresetName, timeState, rate, timeOverlap, timePitchShift, false)

        // Reverb state
        let reverbState = reverbUnit.state
        let space = reverbUnit.space
        let reverbAmount = reverbUnit.amount

        let reverbPreset = ReverbPreset(dummyPresetName, reverbState, space, reverbAmount, false)

        // Delay state
        let delayState = getDelayState() == EffectsUnitState.active ? EffectsUnitState.active : EffectsUnitState.bypassed
        let delayTime = delayNode.delayTime
        let delayAmount = delayNode.wetDryMix
        let cutoff = delayNode.lowPassCutoff
        let feedback = delayNode.feedback

        let delayPreset = DelayPreset(dummyPresetName, delayState, delayAmount, delayTime, feedback, cutoff, false)

        // Filter state
        let filterState = getFilterState() == EffectsUnitState.active ? EffectsUnitState.active : EffectsUnitState.bypassed
        let filterPreset = FilterPreset(dummyPresetName, filterState, allFilterBands(), false)

        // Save the new preset
        let masterPreset = MasterPreset(presetName, eqPreset, pitchPreset, timePreset, reverbPreset, delayPreset, filterPreset, false)
        masterPresets.addPreset(masterPreset)
    }
    
    func getSettingsAsMasterPreset() -> MasterPreset {
        
        let dummyPresetName = "masterPreset_for_soundProfile"
        
        // EQ state
        let eqState = eqUnit.state
        let eqBands = eqUnit.bands
        let eqGlobalGain = eqUnit.globalGain
        
        let eqPreset = EQPreset(dummyPresetName, eqState, eqBands, eqGlobalGain, false)
        
        // Pitch state
        let pitchState = pitchUnit.state
        let pitch = pitchUnit.pitch
        let pitchOverlap = pitchUnit.overlap
        
        let pitchPreset = PitchPreset(dummyPresetName, pitchState, pitch, pitchOverlap, false)
        
        // Time state
        let timeState = timeUnit.state
        let rate = timeUnit.rate
        let timeOverlap = timeUnit.overlap
        let timePitchShift = timeUnit.shiftPitch
        
        let timePreset = TimePreset(dummyPresetName, timeState, rate, timeOverlap, timePitchShift, false)
        
        // Reverb state
        let reverbState = reverbUnit.state
        let space = reverbUnit.space
        let reverbAmount = reverbUnit.amount
        
        let reverbPreset = ReverbPreset(dummyPresetName, reverbState, space, reverbAmount, false)
        
        // Delay state
        let delayState = getDelayState() == EffectsUnitState.active ? EffectsUnitState.active : EffectsUnitState.bypassed
        let delayTime = delayNode.delayTime
        let delayAmount = delayNode.wetDryMix
        let cutoff = delayNode.lowPassCutoff
        let feedback = delayNode.feedback
        
        let delayPreset = DelayPreset(dummyPresetName, delayState, delayAmount, delayTime, feedback, cutoff, false)
        
        // Filter state
        let filterState = getFilterState() == EffectsUnitState.active ? EffectsUnitState.active : EffectsUnitState.bypassed
        let filterPreset = FilterPreset(dummyPresetName, filterState, filterNode.allBands(), false)
        
        return MasterPreset("_masterPreset_for_soundProfile", eqPreset, pitchPreset, timePreset, reverbPreset, delayPreset, filterPreset, false)
    }
    
    func applyMasterPreset(_ preset: MasterPreset) {
        
//        applyEQPreset(preset.eq)
//        applyTimePreset(preset.time)
//        applyReverbPreset(preset.reverb)
        applyDelayPreset(preset.delay)
        applyFilterPreset(preset.filter)
        
        // Apply unit states and determine master state
//        timeNode.bypass = preset.time.state != .active
        delayNode.bypass = preset.delay.state != .active
        filterNode.bypass = preset.filter.state != .active
        
        let needMasterActive = !(delayNode.bypass && filterNode.bypass)
        
        if needMasterActive && masterBypass {
            masterBypass = false
        }
    }
    
    func getVolume() -> Float {
        return playerVolume
    }
    
    func setVolume(_ volume: Float) {
        playerVolume = volume
        if (!muted) {
            playerNode.volume = volume
        }
    }
    
    func mute() {
        playerNode.volume = 0
        muted = true
    }
    
    func unmute() {
        playerNode.volume = playerVolume
        muted = false
    }
    
    func isMuted() -> Bool {
        return muted
    }
    
    func getBalance() -> Float {
        return playerNode.pan
    }
    
    func setBalance(_ balance: Float) {
        playerNode.pan = balance
    }
    
    // MARK: Delay unit functions
    
    func getDelayState() -> EffectsUnitState {
        return masterBypass ? (delaySuppressed ? .suppressed : .bypassed) : (delayNode.bypass ? .bypassed : .active)
    }
    
    func toggleDelayState() -> EffectsUnitState {
        
        let curState = getDelayState()
        let newState: EffectsUnitState
        
        switch curState {
            
        case .active:   newState = .bypassed
            
        case .bypassed: newState = .active
                        if masterBypass {
                            _ = toggleMasterBypass()
                        }
            
        // Master unit is currently bypassed, activate it
        case .suppressed:   newState = .active
                            _ = toggleMasterBypass()
            
        }
        
        delayNode.bypass = newState != .active
        
        return newState
    }
    
    func getDelayAmount() -> Float {
        return delayNode.wetDryMix
    }
    
    func setDelayAmount(_ amount: Float) {
        delayNode.wetDryMix = amount
    }
    
    func getDelayTime() -> Double {
        return delayNode.delayTime
    }
    
    func setDelayTime(_ time: Double) {
        delayNode.delayTime = time
    }
    
    func getDelayFeedback() -> Float {
        return delayNode.feedback
    }
    
    func setDelayFeedback(_ percent: Float) {
        delayNode.feedback = percent
    }
    
    func getDelayLowPassCutoff() -> Float {
        return delayNode.lowPassCutoff
    }
    
    func setDelayLowPassCutoff(_ cutoff: Float) {
        delayNode.lowPassCutoff = cutoff
    }
    
    func saveDelayPreset(_ presetName: String) {
        delayPresets.addPreset(DelayPreset(presetName, .active, delayNode.wetDryMix, delayNode.delayTime, delayNode.feedback, delayNode.lowPassCutoff, false))
    }
    
    func applyDelayPreset(_ preset: DelayPreset) {
        
        setDelayAmount(preset.amount)
        setDelayTime(preset.time)
        setDelayFeedback(preset.feedback)
        setDelayLowPassCutoff(preset.cutoff)
    }
    
    // MARK: Filter unit functions
    
    func getFilterState() -> EffectsUnitState {
        return masterBypass ? (filterSuppressed ? .suppressed : .bypassed) : (filterNode.bypass ? .bypassed : .active)
    }
    
    func toggleFilterState() -> EffectsUnitState {
        
        let curState = getFilterState()
        let newState: EffectsUnitState
        
        switch curState {
            
        case .active:   newState = .bypassed
            
        case .bypassed: newState = .active
                        if masterBypass {
                            _ = toggleMasterBypass()
                        }
            
        // Master unit is currently bypassed, activate it
        case .suppressed:   newState = .active
                            _ = toggleMasterBypass()
            
        }
        
        filterNode.bypass = newState != .active
        
        return newState
    }
    
    func isFilterBypass() -> Bool {
        return filterNode.bypass
    }
    
    func toggleFilterBypass() -> Bool {
        let newState = !filterNode.bypass
        filterNode.bypass = newState
        return newState
    }
    
    func saveFilterPreset(_ presetName: String) {
        
        // Need to clone the filter's bands to create separate identical copies so that changes to the current filter bands don't modify the preset's bands
        var presetBands: [FilterBand] = []
        filterNode.allBands().forEach({presetBands.append($0.clone())})
        
        filterPresets.addPreset(FilterPreset(presetName, .active, presetBands, false))
    }
    
    func applyFilterPreset(_ preset: FilterPreset) {
        
        // Need to clone the filter's bands to create separate identical copies so that changes to the current filter bands don't modify the preset's bands
        var filterBands: [FilterBand] = []
        preset.bands.forEach({filterBands.append($0.clone())})
        filterNode.setBands(filterBands)
    }
    
    func addFilterBand(_ band: FilterBand) -> Int {
        return filterNode.addBand(band)
    }
    
    func updateFilterBand(_ index: Int, _ band: FilterBand) {
        filterNode.updateBand(index, band)
    }
    
    func removeFilterBands(_ indexSet: IndexSet) {
        filterNode.removeBands(indexSet)
    }
    
    func removeAllFilterBands() {
        filterNode.removeAllBands()
    }
    
    func allFilterBands() -> [FilterBand] {
        return filterNode.allBands()
    }
    
    func getFilterBand(_ index: Int) -> FilterBand {
        return filterNode.getBand(index)
    }
    
    // MARK: Miscellaneous functions
    
    func clearSoundTails() {
        
        // Clear sound tails from reverb and delay nodes, if they're active
        
        if (!delayNode.bypass) {
            delayNode.reset()
        }
        
        // TODO: Add reset() and isActive() to all FX units
        if reverbUnit.state == .active {
            reverbUnit.reset()
        }
    }
    
    func persistentState() -> PersistentState {
        
        let state: AudioGraphState = AudioGraphState()
        
        // Volume and pan (balance)
        state.volume = playerVolume
        state.muted = muted
        state.balance = playerNode.pan
        
        state.masterState = masterBypass ? .bypassed : .active
        state.masterUserPresets = masterPresets.userDefinedPresets
        
        // EQ
        state.eqUnitState = eqUnit.persistentState()
        
        // Pitch
        state.pitchUnitState = pitchUnit.persistentState()
        
        // Time
        state.timeUnitState = timeUnit.persistentState()
        
        // Reverb
        state.reverbUnitState = reverbUnit.persistentState()
        
        // Delay
        state.delayState = getDelayState()
        state.delayAmount = delayNode.wetDryMix
        state.delayTime = delayNode.delayTime
        state.delayFeedback = delayNode.feedback
        state.delayLowPassCutoff = delayNode.lowPassCutoff
        state.delayUserPresets = delayPresets.userDefinedPresets
        
        // Filter
        state.filterState = getFilterState()
        state.filterBands = filterNode.allBands()
        state.filterUserPresets = filterPresets.userDefinedPresets
        
        return state
    }
    
    func restartAudioEngine() {
        audioEngineHelper.restart()
    }
    
    func tearDown() {
        
        // Release the audio engine resources
        audioEngine.stop()
    }
}

enum EffectsUnitState: String {
    
    // Master unit on, and effects unit on
    case active
    
    // Effects unit off
    case bypassed
    
    // Master unit off, and effects unit on
    case suppressed
}
