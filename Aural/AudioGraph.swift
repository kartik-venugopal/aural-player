import Cocoa
import AVFoundation

/*
    Wrapper around AVAudioEngine. Manages the AVAudioEngine audio graph.
 */
class AudioGraph: AudioGraphProtocol, PlayerGraphProtocol, RecorderGraphProtocol, PersistentModelObject {
    
    private let audioEngine: AVAudioEngine
    private let mainMixer: AVAudioMixerNode
    
    // Audio graph nodes
    
    // Playback
    internal let playerNode: AVAudioPlayerNode
    
    // Effects
    private let eqNode: ParametricEQ
    private let pitchNode: AVAudioUnitTimePitch
    private let reverbNode: AVAudioUnitReverb
    private let filterNode: FlexibleFilterNode
    private let delayNode: AVAudioUnitDelay
    private let timeNode: VariableRateNode
    
    private let auxMixer: AVAudioMixerNode  // Used for conversions of sample rates / channel counts
    
    // Helper
    private let audioEngineHelper: AudioEngineHelper
    
    internal let nodeForRecorderTap: AVAudioNode
    
    // Temp variables to store individual node bypass states that can be saved/restored when master bypass is toggled
    private var masterBypass: Bool
    
    private var eqSuppressed: Bool
    private var pitchSuppressed: Bool
    private var timeSuppressed: Bool
    private var reverbSuppressed: Bool
    private var delaySuppressed: Bool
    private var filterSuppressed: Bool
    
    // Sound setting value holders
    private var playerVolume: Float
    private var muted: Bool
    private var reverbSpace: AVAudioUnitReverbPreset
    
    // Presets
    private(set) var masterPresets: MasterPresets = MasterPresets()
    
    // Sets up the audio engine
    init(_ state: AudioGraphState) {
        
        playerNode = AVAudioPlayerNode()
        
        audioEngine = AVAudioEngine()
        mainMixer = audioEngine.mainMixerNode
        
        eqNode = ParametricEQ(state.eqType, state.eqSync)
        pitchNode = AVAudioUnitTimePitch()
        reverbNode = AVAudioUnitReverb()
        delayNode = AVAudioUnitDelay()
        filterNode = FlexibleFilterNode()
        timeNode = VariableRateNode()
        auxMixer = AVAudioMixerNode()
        nodeForRecorderTap = mainMixer
        
        audioEngineHelper = AudioEngineHelper(engine: audioEngine)
        
        var nodes = [playerNode, auxMixer]
        nodes.append(contentsOf: eqNode.allNodes)
        nodes.append(contentsOf: [filterNode, pitchNode, timeNode.timePitchNode, timeNode.variNode, reverbNode, delayNode])
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
//        MasterPresets.loadPresets(state.masterUserPresets)
        masterPresets.addPresets(state.masterUserPresets)
        
        // EQ
        eqNode.bypass = state.eqState != .active
        eqSuppressed = state.eqState == .suppressed
        eqNode.setBands(state.eqBands)
        eqNode.globalGain = state.eqGlobalGain
        EQPresets.loadUserDefinedPresets(state.eqUserPresets)
        
        // Pitch
        pitchNode.bypass = state.pitchState != .active
        pitchSuppressed = state.pitchState == .suppressed
        pitchNode.pitch = state.pitch
        pitchNode.overlap = state.pitchOverlap
        PitchPresets.loadUserDefinedPresets(state.pitchUserPresets)
        
        // Time
        timeNode.bypass = state.timeState != .active
        timeSuppressed = state.timeState == .suppressed
        timeNode.rate = state.timeStretchRate
        timeNode.shiftPitch = state.timeShiftPitch
        timeNode.overlap = state.timeOverlap
        TimePresets.loadUserDefinedPresets(state.timeUserPresets)
        
        // Reverb
        reverbNode.bypass = state.reverbState != .active
        reverbSuppressed = state.reverbState == .suppressed
        let avPreset: AVAudioUnitReverbPreset = state.reverbSpace.avPreset
        reverbSpace = avPreset
        reverbNode.loadFactoryPreset(reverbSpace)
        reverbNode.wetDryMix = state.reverbAmount
        ReverbPresets.loadPresets(state.reverbUserPresets)
        
        // Delay
        delayNode.bypass = state.delayState != .active
        delaySuppressed = state.delayState == .suppressed
        delayNode.wetDryMix = state.delayAmount
        delayNode.delayTime = state.delayTime
        delayNode.feedback = state.delayFeedback
        delayNode.lowPassCutoff = state.delayLowPassCutoff
        DelayPresets.loadUserDefinedPresets(state.delayUserPresets)
        
        // Filter
        filterNode.bypass = state.filterState != .active
        filterSuppressed = state.filterState == .suppressed
        filterNode.addBands(state.filterBands)
        FilterPresets.loadUserDefinedPresets(state.filterUserPresets)
    }

    private func bypassAllUnits() {
        
        eqNode.bypass = true
        [reverbNode, delayNode, filterNode].forEach({$0.bypass = true})
        pitchNode.bypass = true
        timeNode.bypass = true
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
            
            eqSuppressed = !eqNode.bypass
            pitchSuppressed = !pitchNode.bypass
            timeSuppressed = !timeNode.bypass
            reverbSuppressed = !reverbNode.bypass
            delaySuppressed = !delayNode.bypass
            filterSuppressed = !filterNode.bypass
            
            bypassAllUnits()
            
        } else {
            
            // Inactive -> Active
            
            eqNode.bypass = !eqSuppressed
            pitchNode.bypass = !pitchSuppressed
            timeNode.bypass = !timeSuppressed
            reverbNode.bypass = !reverbSuppressed
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
        let eqState = getEQState() == EffectsUnitState.active ? EffectsUnitState.active : EffectsUnitState.bypassed
        let eqBands = eqNode.allBands()
        let eqGlobalGain = eqNode.globalGain
        
        let eqPreset = EQPreset(dummyPresetName, eqState, eqBands, eqGlobalGain, false)
        
        // Pitch state
        let pitchState = getPitchState() == EffectsUnitState.active ? EffectsUnitState.active : EffectsUnitState.bypassed
        let pitch = pitchNode.pitch
        let pitchOverlap = pitchNode.overlap
        
        let pitchPreset = PitchPreset(dummyPresetName, pitchState, pitch, pitchOverlap, false)
        
        // Time state
        let timeState = getTimeState() == EffectsUnitState.active ? EffectsUnitState.active : EffectsUnitState.bypassed
        let rate = timeNode.rate
        let timeOverlap = timeNode.overlap
        let timePitchShift = timeNode.shiftPitch
        
        let timePreset = TimePreset(dummyPresetName, timeState, rate, timeOverlap, timePitchShift, false)
        
        // Reverb state
        let reverbState = getReverbState() == EffectsUnitState.active ? EffectsUnitState.active : EffectsUnitState.bypassed
        let space = getReverbSpace()
        let reverbAmount = reverbNode.wetDryMix
        
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
        let eqState = getEQState() == EffectsUnitState.active ? EffectsUnitState.active : EffectsUnitState.bypassed
        let eqBands = eqNode.allBands()
        let eqGlobalGain = eqNode.globalGain
        
        let eqPreset = EQPreset(dummyPresetName, eqState, eqBands, eqGlobalGain, false)
        
        // Pitch state
        let pitchState = getPitchState() == EffectsUnitState.active ? EffectsUnitState.active : EffectsUnitState.bypassed
        let pitch = pitchNode.pitch
        let pitchOverlap = pitchNode.overlap
        
        let pitchPreset = PitchPreset(dummyPresetName, pitchState, pitch, pitchOverlap, false)
        
        // Time state
        let timeState = getTimeState() == EffectsUnitState.active ? EffectsUnitState.active : EffectsUnitState.bypassed
        let rate = timeNode.rate
        let timeOverlap = timeNode.overlap
        let timePitchShift = timeNode.shiftPitch
        
        let timePreset = TimePreset(dummyPresetName, timeState, rate, timeOverlap, timePitchShift, false)
        
        // Reverb state
        let reverbState = getReverbState() == EffectsUnitState.active ? EffectsUnitState.active : EffectsUnitState.bypassed
        let space = getReverbSpace()
        let reverbAmount = reverbNode.wetDryMix
        
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
        
        applyEQPreset(preset.eq)
        applyPitchPreset(preset.pitch)
        applyTimePreset(preset.time)
        applyReverbPreset(preset.reverb)
        applyDelayPreset(preset.delay)
        applyFilterPreset(preset.filter)
        
        // Apply unit states and determine master state
        eqNode.bypass = preset.eq.state != .active
        pitchNode.bypass = preset.pitch.state != .active
        timeNode.bypass = preset.time.state != .active
        reverbNode.bypass = preset.reverb.state != .active
        delayNode.bypass = preset.delay.state != .active
        filterNode.bypass = preset.filter.state != .active
        
        let needMasterActive = !(eqNode.bypass && pitchNode.bypass && timeNode.bypass && reverbNode.bypass && delayNode.bypass && filterNode.bypass)
        
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
    
    // MARK: EQ unit functions
    
    func getEQSync() -> Bool {
        return eqNode.sync
    }
    
    func toggleEQSync() -> Bool {
        return eqNode.toggleSync()
    }
    
    func getEQType() -> EQType {
        return eqNode.type
    }
    
    func chooseEQType(_ type: EQType) {
        eqNode.chooseType(type)
    }
    
    func getEQState() -> EffectsUnitState {
        return masterBypass ? (eqSuppressed ? .suppressed : .bypassed) : (eqNode.bypass ? .bypassed : .active)
    }
    
    // Toggles the state of the Equalizer audio effects unit, and returns its new state
    func toggleEQState() -> EffectsUnitState {
        
        let curState = getEQState()
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
        
        eqNode.bypass = newState != .active
        
        return newState
    }
    
    func getEQGlobalGain() -> Float {
        return eqNode.globalGain
    }
    
    func getEQBands() -> [Int: Float] {
        return eqNode.allBands()
    }
    
    func setEQGlobalGain(_ gain: Float) {
        eqNode.globalGain = gain
    }
    
    func setEQBand(_ index: Int , gain: Float) {
        eqNode.setBand(index, gain: gain)
    }
    
    func setEQBands(_ bands: [Int: Float]) {
        eqNode.setBands(bands)
    }
    
    func increaseBass(_ increment: Float) -> [Int : Float] {
        return eqNode.increaseBass(increment)
    }
    
    func decreaseBass(_ decrement: Float) -> [Int : Float] {
        return eqNode.decreaseBass(decrement)
    }
    
    func increaseMids(_ increment: Float) -> [Int: Float] {
        return eqNode.increaseMids(increment)
    }
    
    func decreaseMids(_ decrement: Float) -> [Int: Float] {
        return eqNode.decreaseMids(decrement)
    }
    
    func increaseTreble(_ increment: Float) -> [Int: Float] {
        return eqNode.increaseTreble(increment)
    }
    
    func decreaseTreble(_ decrement: Float) -> [Int: Float] {
        return eqNode.decreaseTreble(decrement)
    }
    
    func saveEQPreset(_ presetName: String) {
     
        let eqState = getEQState() == EffectsUnitState.active ? EffectsUnitState.active : EffectsUnitState.bypassed
        EQPresets.addUserDefinedPreset(presetName, eqState, eqNode.allBands(), eqNode.globalGain)
    }
    
    func applyEQPreset(_ preset: EQPreset) {
        
        setEQBands(preset.bands)
        setEQGlobalGain(preset.globalGain)
    }
    
    // MARK: Pitch shift unit functions
    
    func getPitchState() -> EffectsUnitState {
        return masterBypass ? (pitchSuppressed ? .suppressed : .bypassed) : (pitchNode.bypass ? .bypassed : .active)
    }
    
    // Toggles the state of the Equalizer audio effects unit, and returns its new state
    func togglePitchState() -> EffectsUnitState {
        
        let curState = getPitchState()
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
        
        pitchNode.bypass = newState != .active
        
        return newState
    }
    
    func getPitch() -> Float {
        return pitchNode.pitch
    }
    
    func setPitch(_ pitch: Float) {
        pitchNode.pitch = pitch
    }
    
    func getPitchOverlap() -> Float {
        return pitchNode.overlap
    }
    
    func setPitchOverlap(_ overlap: Float) {
        pitchNode.overlap = overlap
    }
    
    func savePitchPreset(_ presetName: String) {
        
        let pitchState = getPitchState() == EffectsUnitState.active ? EffectsUnitState.active : EffectsUnitState.bypassed
        PitchPresets.addUserDefinedPreset(presetName, pitchState, pitchNode.pitch, pitchNode.overlap)
    }
    
    func applyPitchPreset(_ preset: PitchPreset) {
        
        setPitch(preset.pitch)
        setPitchOverlap(preset.overlap)
    }
    
    // MARK: Time stretch unit functions
    
    func getTimeState() -> EffectsUnitState {
        return masterBypass ? (timeSuppressed ? .suppressed : .bypassed) : (timeNode.bypass ? .bypassed : .active)
    }
    
    // Toggles the state of the Equalizer audio effects unit, and returns its new state
    func toggleTimeState() -> EffectsUnitState {
        
        let curState = getTimeState()
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
        
        timeNode.bypass = newState != .active
        
        return newState
    }
    
    func isTimePitchShift() -> Bool {
        return timeNode.shiftPitch
    }
    
    func toggleTimePitchShift() -> Bool {
        
        let newState = !timeNode.shiftPitch
        timeNode.shiftPitch = newState
        return newState
    }
    
    func getTimeStretchRate() -> Float {
        return timeNode.rate
    }
    
    func getTimePitchShift() -> Float {
        return timeNode.pitch
    }
    
    func setTimeStretchRate(_ rate: Float) {
        timeNode.rate = rate
    }
    
    func getTimeOverlap() -> Float {
        return timeNode.overlap
    }
    
    func setTimeOverlap(_ overlap: Float) {
        timeNode.overlap = overlap
    }
    
    func saveTimePreset(_ presetName: String) {
        
        let timeState = getTimeState() == EffectsUnitState.active ? EffectsUnitState.active : EffectsUnitState.bypassed
        TimePresets.addUserDefinedPreset(presetName, timeState, timeNode.rate, timeNode.overlap, timeNode.shiftPitch)
    }
    
    func applyTimePreset(_ preset: TimePreset) {
        
        setTimeStretchRate(preset.rate)
        setTimeOverlap(preset.overlap)
        timeNode.shiftPitch = preset.pitchShift
    }
    
    // MARK: Reverb unit functions
    
    func getReverbState() -> EffectsUnitState {
        return masterBypass ? (reverbSuppressed ? .suppressed : .bypassed) : (reverbNode.bypass ? .bypassed : .active)
    }
    
    func toggleReverbState() -> EffectsUnitState {
        
        let curState = getReverbState()
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
        
        reverbNode.bypass = newState != .active
        
        return newState
    }
    
    func getReverbSpace() -> ReverbSpaces {
        return ReverbSpaces.mapFromAVPreset(reverbSpace)
    }
    
    func setReverbSpace(_ space: ReverbSpaces) {
        
        let avPreset: AVAudioUnitReverbPreset = space.avPreset
        self.reverbSpace = avPreset
        reverbNode.loadFactoryPreset(self.reverbSpace)
    }
    
    func getReverbAmount() -> Float {
        return reverbNode.wetDryMix
    }
    
    func setReverbAmount(_ amount: Float) {
        reverbNode.wetDryMix = amount
    }
    
    func saveReverbPreset(_ presetName: String) {
        
        let reverbState = getReverbState() == EffectsUnitState.active ? EffectsUnitState.active : EffectsUnitState.bypassed
        ReverbPresets.addUserDefinedPreset(presetName, reverbState, getReverbSpace(), reverbNode.wetDryMix)
    }
    
    func applyReverbPreset(_ preset: ReverbPreset) {
        
        setReverbSpace(preset.space)
        setReverbAmount(preset.amount)
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
        
        let delayState = (getDelayState() == EffectsUnitState.active ? EffectsUnitState.active : EffectsUnitState.bypassed)
        DelayPresets.addUserDefinedPreset(presetName, delayState, delayNode.wetDryMix, delayNode.delayTime, delayNode.feedback, delayNode.lowPassCutoff)
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
        
        let filterState = getFilterState() == EffectsUnitState.active ? EffectsUnitState.active : EffectsUnitState.bypassed
        
        // Need to clone the filter's bands to create separate identical copies so that changes to the current filter bands don't modify the preset's bands
        var presetBands: [FilterBand] = []
        filterNode.allBands().forEach({presetBands.append($0.clone())})
        FilterPresets.addUserDefinedPreset(presetName, filterState, presetBands)
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
        
        if (!reverbNode.bypass) {
            reverbNode.reset()
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
        state.eqState = getEQState()
        state.eqType = eqNode.type
        state.eqSync = eqNode.sync
        state.eqBands = eqNode.allBands()
        state.eqGlobalGain = eqNode.globalGain
        state.eqUserPresets = EQPresets.userDefinedPresets
        
        // Pitch
        state.pitchState = getPitchState()
        state.pitch = pitchNode.pitch
        state.pitchOverlap = pitchNode.overlap
        state.pitchUserPresets = PitchPresets.userDefinedPresets
        
        // Time
        state.timeState = getTimeState()
        state.timeStretchRate = timeNode.rate
        state.timeShiftPitch = timeNode.shiftPitch
        state.timeOverlap = timeNode.overlap
        state.timeUserPresets = TimePresets.userDefinedPresets
        
        // Reverb
        state.reverbState = getReverbState()
        state.reverbSpace = ReverbSpaces.mapFromAVPreset(reverbSpace)
        state.reverbAmount = reverbNode.wetDryMix
        state.reverbUserPresets = ReverbPresets.allPresets()
        
        // Delay
        state.delayState = getDelayState()
        state.delayAmount = delayNode.wetDryMix
        state.delayTime = delayNode.delayTime
        state.delayFeedback = delayNode.feedback
        state.delayLowPassCutoff = delayNode.lowPassCutoff
        state.delayUserPresets = DelayPresets.userDefinedPresets
        
        // Filter
        state.filterState = getFilterState()
        state.filterBands = filterNode.allBands()
        state.filterUserPresets = FilterPresets.userDefinedPresets
        
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

enum EQType: String {
    
    case tenBand
    case fifteenBand
}
