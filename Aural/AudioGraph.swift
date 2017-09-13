import Cocoa
import AVFoundation

/*
    Wrapper around AVAudioEngine. Manages the AVAudioEngine audio graph.
 */
class AudioGraph: AudioGraphProtocol, PlayerGraphProtocol, RecorderGraphProtocol {
    
    private let audioEngine: AVAudioEngine
    private let mainMixer: AVAudioMixerNode
    
    // Audio graph nodes
    internal let playerNode: AVAudioPlayerNode
    private let eqNode: ParametricEQNode
    private let pitchNode: AVAudioUnitTimePitch
    private let reverbNode: AVAudioUnitReverb
    private let filterNode: MultiBandStopFilterNode
    private let delayNode: AVAudioUnitDelay
    private let timeNode: AVAudioUnitTimePitch
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
        timeNode = AVAudioUnitTimePitch()
        auxMixer = AVAudioMixerNode()
        nodeForRecorderTap = mainMixer
        
        audioEngineHelper = AudioEngineHelper(engine: audioEngine)
        
        audioEngineHelper.addNodes([playerNode, auxMixer, eqNode, filterNode, pitchNode, reverbNode, delayNode, timeNode])
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
        eqNode.setBands(state.eqBands)
        eqNode.globalGain = state.eqGlobalGain
        
        // Pitch
        pitchNode.bypass = state.pitchBypass
        pitchNode.pitch = state.pitch
        pitchNode.overlap = state.pitchOverlap
        
        // Time
        timeNode.bypass = state.timeBypass
        timeNode.rate = state.timeStretchRate
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
    
    func setEQGlobalGain(_ gain: Float) {
        eqNode.globalGain = gain
    }
    
    func setEQBand(_ freq: Int , gain: Float) {
        eqNode.setBand(Float(freq), gain: gain)
    }
    
    func setEQBands(_ bands: [Int: Float]) {
        eqNode.setBands(bands)
    }
    
    func togglePitchBypass() -> Bool {
        let newState = !pitchNode.bypass
        pitchNode.bypass = newState
        return newState
    }
    
    func setPitch(_ pitch: Float) {
        pitchNode.pitch = pitch
    }
    
    func setPitchOverlap(_ overlap: Float) {
        pitchNode.overlap = overlap
    }
    
    func toggleTimeBypass() -> Bool {
        let newState = !timeNode.bypass
        timeNode.bypass = newState
        return newState
    }
    
    func isTimeBypass() -> Bool {
        return timeNode.bypass
    }
    
    func setTimeStretchRate(_ rate: Float) {
        timeNode.rate = rate
    }
    
    func setTimeOverlap(_ overlap: Float) {
        timeNode.overlap = overlap
    }
    
    func toggleReverbBypass() -> Bool {
        let newState = !reverbNode.bypass
        reverbNode.bypass = newState
        return newState
    }
    
    func setReverb(_ preset: ReverbPresets) {
        
        let avPreset: AVAudioUnitReverbPreset = preset.avPreset
        reverbPreset = avPreset
        reverbNode.loadFactoryPreset(reverbPreset)
    }
    
    func setReverbAmount(_ amount: Float) {
        reverbNode.wetDryMix = amount
    }
    
    func toggleDelayBypass() -> Bool {
        let newState = !delayNode.bypass
        delayNode.bypass = newState
        return newState
    }
    
    func setDelayAmount(_ amount: Float) {
        delayNode.wetDryMix = amount
    }
    
    func setDelayTime(_ time: Double) {
        delayNode.delayTime = time
    }
    
    func setDelayFeedback(_ percent: Float) {
        delayNode.feedback = percent
    }
    
    func setDelayLowPassCutoff(_ cutoff: Float) {
        delayNode.lowPassCutoff = cutoff
    }
    
    func toggleFilterBypass() -> Bool {
        let newState = !filterNode.bypass
        filterNode.bypass = newState
        return newState
    }
    
    func setFilterBassBand(_ min: Float, _ max: Float) {
        filterNode.setFilterBassBand(min, max)
    }
    
    func setFilterMidBand(_ min: Float, _ max: Float) {
        filterNode.setFilterMidBand(min, max)
    }
    
    func setFilterTrebleBand(_ min: Float, _ max: Float) {
        filterNode.setFilterTrebleBand(min, max)
    }
    
    func clearSoundTails() {
        
        // Clear sound tails from reverb and delay nodes, if they're active
        
        if (!delayNode.bypass) {
            delayNode.reset()
        }
        
        if (!reverbNode.bypass) {
            reverbNode.reset()
        }
    }
    
    func getPersistentState() -> AudioGraphState {
        
        let state: AudioGraphState = AudioGraphState()
        
        // Volume and pan (balance)
        state.volume = playerVolume
        state.muted = muted
        state.balance = playerNode.pan
        
        // EQ
        for band in eqNode.bands {
            state.eqBands[Int(band.frequency)] = band.gain
        }
        state.eqGlobalGain = eqNode.globalGain
        
        // Pitch
        state.pitchBypass = pitchNode.bypass
        state.pitch = pitchNode.pitch
        state.pitchOverlap = pitchNode.overlap
        
        // Time
        state.timeBypass = timeNode.bypass
        state.timeStretchRate = timeNode.rate
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
