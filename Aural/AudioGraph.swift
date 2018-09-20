import Cocoa
import AVFoundation

/*
    Wrapper around AVAudioEngine. Manages the AVAudioEngine audio graph.
 */
class AudioGraph: AudioGraphProtocol, PlayerGraphProtocol, RecorderGraphProtocol, PersistentModelObject {
    
    private let audioEngine: AVAudioEngine
    private let mainMixer: AVAudioMixerNode
    
    // Audio graph nodes
    internal let playerNode: AVAudioPlayerNode
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
    
    // Sound setting value holders
    private var playerVolume: Float
    private var muted: Bool
    private var reverbPreset: AVAudioUnitReverbPreset
    
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
        
        // EQ
        eqNode.bypass = state.eqBypass
        eqNode.setBands(state.eqBands)
        eqNode.globalGain = state.eqGlobalGain
        EQPresets.loadUserDefinedPresets(state.eqUserPresets)
        
        // Pitch
        pitchNode.bypass = state.pitchBypass
        pitchNode.pitch = state.pitch
        pitchNode.overlap = state.pitchOverlap
        PitchPresets.loadUserDefinedPresets(state.pitchUserPresets)
        
        // Time
        timeNode.bypass = state.timeBypass
        timeNode.rate = state.timeStretchRate
        timeNode.shiftPitch = state.timeShiftPitch
        timeNode.overlap = state.timeOverlap
        
        // Reverb
        reverbNode.bypass = state.reverbBypass
        let avPreset: AVAudioUnitReverbPreset = state.reverbPreset.avPreset
        reverbPreset = avPreset
        reverbNode.loadFactoryPreset(reverbPreset)
        reverbNode.wetDryMix = state.reverbAmount
        
        // Delay
        delayNode.bypass = state.delayBypass
        delayNode.wetDryMix = state.delayAmount
        delayNode.delayTime = state.delayTime
        delayNode.feedback = state.delayFeedback
        delayNode.lowPassCutoff = state.delayLowPassCutoff
        
        // Filter
        filterNode.bypass = state.filterBypass
        filterNode.setFilterBassBand(state.filterBassMin, state.filterBassMax)
        filterNode.setFilterMidBand(state.filterMidMin, state.filterMidMax)
        filterNode.setFilterTrebleBand(state.filterTrebleMin, state.filterTrebleMax)
    }
    
    func reconnectPlayerNodeWithFormat(_ format: AVAudioFormat) {
        audioEngineHelper.reconnectNodes(playerNode, outputNode: auxMixer, format: format)
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
    
    func isEQBypass() -> Bool {
        return eqNode.bypass
    }
    
    func toggleEQBypass() -> Bool {
        let newState = !eqNode.bypass
        eqNode.bypass = newState
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
    
    func isReverbBypass() -> Bool {
        return reverbNode.bypass
    }
    
    func toggleReverbBypass() -> Bool {
        let newState = !reverbNode.bypass
        reverbNode.bypass = newState
        return newState
    }
    
    func getReverbPreset() -> ReverbPresets {
        return ReverbPresets.mapFromAVPreset(reverbPreset)
    }
    
    func setReverb(_ preset: ReverbPresets) {
        
        let avPreset: AVAudioUnitReverbPreset = preset.avPreset
        reverbPreset = avPreset
        reverbNode.loadFactoryPreset(reverbPreset)
    }
    
    func getReverbAmount() -> Float {
        return reverbNode.wetDryMix
    }
    
    func setReverbAmount(_ amount: Float) {
        reverbNode.wetDryMix = amount
    }
    
    // MARK: Delay unit functions
    
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
        
        // EQ
        state.eqBypass = eqNode.bypass
        state.eqBands = eqNode.allBands()
        state.eqGlobalGain = eqNode.globalGain
        state.eqUserPresets = EQPresets.userDefinedPresets
        
        // Pitch
        state.pitchBypass = pitchNode.bypass
        state.pitch = pitchNode.pitch
        state.pitchOverlap = pitchNode.overlap
        state.pitchUserPresets = PitchPresets.userDefinedPresets
        
        // Time
        state.timeBypass = timeNode.bypass
        state.timeStretchRate = timeNode.rate
        state.timeShiftPitch = timeNode.shiftPitch
        state.timeOverlap = timeNode.overlap
        
        // Reverb
        state.reverbBypass = reverbNode.bypass
        state.reverbPreset = ReverbPresets.mapFromAVPreset(reverbPreset)
        state.reverbAmount = reverbNode.wetDryMix
        
        // Delay
        state.delayBypass = delayNode.bypass
        state.delayAmount = delayNode.wetDryMix
        state.delayTime = delayNode.delayTime
        state.delayFeedback = delayNode.feedback
        state.delayLowPassCutoff = delayNode.lowPassCutoff
        
        // Filter
        state.filterBypass = filterNode.bypass
        let filterBands = filterNode.getBands()
        state.filterBassMin = filterBands.bass.min
        state.filterBassMax = filterBands.bass.max
        state.filterMidMin = filterBands.mid.min
        state.filterMidMax = filterBands.mid.max
        state.filterTrebleMin = filterBands.treble.min
        state.filterTrebleMax = filterBands.treble.max
        
        return state
    }
    
    func tearDown() {
        
        // Stop the player and release the audio engine resources
        audioEngine.stop()
    }
}
