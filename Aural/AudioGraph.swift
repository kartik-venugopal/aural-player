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
    private let eqNode: ParametricEQNode
    private let pitchNode: AVAudioUnitTimePitch
    private let reverbNode: AVAudioUnitReverb
    private let filterNode: MultiBandStopFilterNode
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
    
    // Sets up the audio engine
    init(_ state: AudioGraphState) {
        
        playerNode = AVAudioPlayerNode()
        
        audioEngine = AVAudioEngine()
        mainMixer = audioEngine.mainMixerNode
        eqNode = ParametricEQNode()
        pitchNode = AVAudioUnitTimePitch()
        reverbNode = AVAudioUnitReverb()
        delayNode = AVAudioUnitDelay()
        filterNode = MultiBandStopFilterNode()
        timeNode = VariableRateNode()
        auxMixer = AVAudioMixerNode()
        nodeForRecorderTap = mainMixer
        
        audioEngineHelper = AudioEngineHelper(engine: audioEngine)
        
        audioEngineHelper.addNodes([playerNode, auxMixer, eqNode, filterNode, pitchNode, reverbNode, delayNode, timeNode.timePitchNode, timeNode.variNode])
        
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
        
        masterBypass = state.masterBypass
        
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
        filterNode.setFilterBassBand(state.filterBassMin, state.filterBassMax)
        filterNode.setFilterMidBand(state.filterMidMin, state.filterMidMax)
        filterNode.setFilterTrebleBand(state.filterTrebleMin, state.filterTrebleMax)
        FilterPresets.loadUserDefinedPresets(state.filterUserPresets)
    }

    private func bypassAllUnits() {
        
        [eqNode, reverbNode, delayNode, filterNode].forEach({$0.bypass = true})
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
            
            // If a unit was active (i.e. not bypassed), mark it as now being suppressed by the master bypass
            
            eqSuppressed = !eqNode.bypass
            pitchSuppressed = !pitchNode.bypass
            timeSuppressed = !timeNode.bypass
            reverbSuppressed = !reverbNode.bypass
            delaySuppressed = !delayNode.bypass
            filterSuppressed = !filterNode.bypass
            
            bypassAllUnits()
            
        } else {
            
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
    
    func increaseBass() -> [Int : Float] {
        return eqNode.increaseBass()
    }
    
    func decreaseBass() -> [Int : Float] {
        return eqNode.decreaseBass()
    }
    
    func increaseMids() -> [Int: Float] {
        return eqNode.increaseMids()
    }
    
    func decreaseMids() -> [Int: Float] {
        return eqNode.decreaseMids()
    }
    
    func increaseTreble() -> [Int: Float] {
        return eqNode.increaseTreble()
    }
    
    func decreaseTreble() -> [Int: Float] {
        return eqNode.decreaseTreble()
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
    
    func togglePitchBypass() -> Bool {
        let newState = !pitchNode.bypass
        pitchNode.bypass = newState
        return newState
    }
    
    func isPitchBypass() -> Bool {
        return pitchNode.bypass
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
    
    // MARK: Time stretch unit functions
    
    func getTimeState() -> EffectsUnitState {
        return masterBypass ? (timeSuppressed ? .suppressed : .bypassed) : (timeNode.bypass ? .bypassed : .active)
    }
    
    func isTimeBypass() -> Bool {
        return timeNode.bypass
    }
    
    func toggleTimeBypass() -> Bool {
        
        let newState = !timeNode.bypass
        timeNode.bypass = newState
        
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
    
    // MARK: Reverb unit functions
    
    func getReverbState() -> EffectsUnitState {
        return masterBypass ? (reverbSuppressed ? .suppressed : .bypassed) : (reverbNode.bypass ? .bypassed : .active)
    }
    
    func isReverbBypass() -> Bool {
        return reverbNode.bypass
    }
    
    func toggleReverbBypass() -> Bool {
        let newState = !reverbNode.bypass
        reverbNode.bypass = newState
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
    
    // MARK: Delay unit functions
    
    func getDelayState() -> EffectsUnitState {
        return masterBypass ? (delaySuppressed ? .suppressed : .bypassed) : (delayNode.bypass ? .bypassed : .active)
    }
    
    func isDelayBypass() -> Bool {
        return delayNode.bypass
    }
    
    func toggleDelayBypass() -> Bool {
        let newState = !delayNode.bypass
        delayNode.bypass = newState
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
    
    // MARK: Filter unit functions
    
    func getFilterState() -> EffectsUnitState {
        return masterBypass ? (filterSuppressed ? .suppressed : .bypassed) : (filterNode.bypass ? .bypassed : .active)
    }
    
    func isFilterBypass() -> Bool {
        return filterNode.bypass
    }
    
    func toggleFilterBypass() -> Bool {
        let newState = !filterNode.bypass
        filterNode.bypass = newState
        return newState
    }
    
    func getFilterBassBand() -> (min: Float, max: Float) {
        return filterNode.getBands().bass
    }
    
    func setFilterBassBand(_ min: Float, _ max: Float) {
        filterNode.setFilterBassBand(min, max)
    }
    
    func getFilterMidBand() -> (min: Float, max: Float) {
        return filterNode.getBands().mid
    }
    
    func setFilterMidBand(_ min: Float, _ max: Float) {
        filterNode.setFilterMidBand(min, max)
    }
    
    func getFilterTrebleBand() -> (min: Float, max: Float) {
        return filterNode.getBands().treble
    }
    
    func setFilterTrebleBand(_ min: Float, _ max: Float) {
        filterNode.setFilterTrebleBand(min, max)
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
        
        state.masterBypass = masterBypass
        
        // EQ
        state.eqState = getEQState()
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
        let filterBands = filterNode.getBands()
        state.filterBassMin = filterBands.bass.min
        state.filterBassMax = filterBands.bass.max
        state.filterMidMin = filterBands.mid.min
        state.filterMidMax = filterBands.mid.max
        state.filterTrebleMin = filterBands.treble.min
        state.filterTrebleMax = filterBands.treble.max
        state.filterUserPresets = FilterPresets.userDefinedPresets
        
        return state
    }
    
    func tearDown() {
        
        // Stop the player and release the audio engine resources
        playerNode.stop()
        playerNode.reset()
        
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
