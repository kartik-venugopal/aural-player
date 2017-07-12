/*
Wrapper around AVAudioEngine. Handles all audio-related operations ... playback, effects (DSP), etc. Receives calls from PlayerDelegate to modify settings and perform playback.
*/

import Cocoa
import AVFoundation

class Player: AuralPlayer, AuralSoundTuner, EventPublisher {
    
    private static let singleton: Player = Player()
    
    static func instance() -> Player {
        return singleton
    }
    
    private let playerNode: AVAudioPlayerNode
    private let audioEngine: AVAudioEngine
    private let mainMixer: AVAudioMixerNode
    
    // Used for conversions of sample rates / channel counts
    private let auxMixer: AVAudioMixerNode
    
    private let eqNode: ParametricEQNode
    private let timePitchNode: AVAudioUnitTimePitch
    private let reverbNode: AVAudioUnitReverb
    private let filterNode: FilterNode
    
    // TODO
    private let delayNode: AVAudioUnitDelay
//    private let distortionNode: AVAudioUnitDistortion
    
    // Helper
    private let audioEngineHelper: AudioEngineHelper
    
    // Sound setting value holders
    private var playerVolume: Float
    private var muted: Bool
    private var reverbPreset: AVAudioUnitReverbPreset
    
    private var bufferManager: BufferManager
    
    // Currently playing track
    private var playingTrack: Track?
    
    // Current playback position (frame)
    private var startFrame: AVAudioFramePosition?
    
    // Sets up the audio engine
    private init() {
        
        playerNode = AVAudioPlayerNode()

        playerVolume = PlayerDefaults.volume
        muted = PlayerDefaults.muted
        reverbPreset = PlayerDefaults.reverbPreset.avPreset
        
        audioEngine = AVAudioEngine()
        mainMixer = audioEngine.mainMixerNode
        eqNode = ParametricEQNode()
        timePitchNode = AVAudioUnitTimePitch()
        reverbNode = AVAudioUnitReverb()
        delayNode = AVAudioUnitDelay()
        filterNode = FilterNode()
        auxMixer = AVAudioMixerNode()
        
        audioEngineHelper = AudioEngineHelper(engine: audioEngine)
        
        audioEngineHelper.addNodes([playerNode, auxMixer, eqNode, filterNode, timePitchNode, reverbNode, delayNode])
        audioEngineHelper.connectNodes()
        audioEngineHelper.prepareAndStart()
        
        bufferManager = BufferManager(playerNode: playerNode)
        
        loadPlayerState(SavedPlayerState.defaults)
        
        // Register self as a publisher of playback completion events
        EventRegistry.registerPublisher(.PlaybackCompleted, publisher: self)
    }
    
    func loadPlayerState(state: SavedPlayerState) {
        
        playerVolume = state.volume
        muted = state.muted
        playerNode.volume = muted ? 0 : playerVolume
        playerNode.pan = state.balance
        
        // EQ
        eqNode.setBands(state.eqBands)
        eqNode.globalGain = state.eqGlobalGain
        
        // Pitch
        timePitchNode.bypass = state.pitchBypass
        timePitchNode.pitch = state.pitch
        timePitchNode.overlap = state.pitchOverlap
        
        // Reverb
        reverbNode.bypass = state.reverbBypass
        setReverb(state.reverbPreset)
        reverbNode.wetDryMix = state.reverbAmount
        
        // Delay
        delayNode.bypass = state.delayBypass
        delayNode.wetDryMix = state.delayAmount
        delayNode.delayTime = state.delayTime
        delayNode.feedback = state.delayFeedback
        delayNode.lowPassCutoff = state.delayLowPassCutoff
        
        // Filter
        filterNode.bypass = state.filterBypass
        filterNode.highPassBand.frequency = state.filterHighPassCutoff
        filterNode.lowPassBand.frequency = state.filterLowPassCutoff
    }
    
    // Prepares the player to play a given track
    private func initPlayer(track: Track) {
        
        let format = track.avFile!.processingFormat
        
        // Disconnect player and reconnect with the file's processing format        
        audioEngineHelper.reconnectNodes(playerNode, outputNode: auxMixer, format: format)
    }
    
    func play(track: Track) {
        
        // Stop if currently playing
        stop()
        
        playingTrack = nil
        playingTrack = track
        
        startFrame = BufferManager.FRAME_ZERO
        initPlayer(track)
        bufferManager.play(track.avFile!)
    }
    
    func pause() {
        playerNode.pause()
        bufferManager.pause()
    }
    
    func resume() {
        bufferManager.resume()
        playerNode.play()
    }
    
    // In seconds
    func getSeekPosition() -> Double {
        
        let nodeTime: AVAudioTime? = playerNode.lastRenderTime
        
        if (nodeTime != nil) {
            
            let playerTime: AVAudioTime? = playerNode.playerTimeForNodeTime(nodeTime!)
            
            if (playerTime != nil) {
                
                let lastFrame = (playerTime?.sampleTime)!
                let seconds: Double = Double(startFrame! + lastFrame) / (playerTime?.sampleRate)!
                
                if (seconds >= playingTrack!.duration) {
                    playbackCompleted()
                    return 0
                }
                
                return seconds
            }
        }
        
        // This should never happen (player is not playing)
        return 0
    }
    
    func getVolume() -> Float {
        return playerVolume
    }
    
    func setVolume(volume: Float) {
        playerNode.volume = volume
        playerVolume = volume
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
    
    func setBalance(balance: Float) {
        playerNode.pan = balance
    }
    
    func setEQGlobalGain(gain: Float) {
        eqNode.globalGain = gain
    }
    
    func setEQBand(freq: Int , gain: Float) {
        eqNode.setBand(Float(freq), gain: gain)
    }
    
    func setEQBands(bands: [Int: Float]) {
        eqNode.setBands(bands)
    }
    
    func togglePitchBypass() -> Bool {
        let newState = !timePitchNode.bypass
        timePitchNode.bypass = newState
        return newState
    }
    
    func setPitch(pitch: Float) {
        timePitchNode.pitch = pitch
    }
    
    func setPitchOverlap(overlap: Float) {
        timePitchNode.overlap = overlap
    }
    
    func toggleReverbBypass() -> Bool {
        let newState = !reverbNode.bypass
        reverbNode.bypass = newState
        return newState
    }
    
    func setReverb(preset: ReverbPresets) {
        
        let avPreset: AVAudioUnitReverbPreset = preset.avPreset
        reverbPreset = avPreset
        reverbNode.loadFactoryPreset(reverbPreset)
    }
    
    func setReverbAmount(amount: Float) {
        reverbNode.wetDryMix = amount
    }
    
    func toggleDelayBypass() -> Bool {
        let newState = !delayNode.bypass
        delayNode.bypass = newState
        return newState
    }
    
    func setDelayAmount(amount: Float) {
        delayNode.wetDryMix = amount
    }
    
    func setDelayTime(time: Double) {
        delayNode.delayTime = time
    }
    
    func setDelayFeedback(percent: Float) {
        delayNode.feedback = percent
    }
    
    func setDelayLowPassCutoff(cutoff: Float) {
        delayNode.lowPassCutoff = cutoff
    }
    
    func toggleFilterBypass() -> Bool {
        let newState = !filterNode.bypass
        filterNode.bypass = newState
        return newState
    }
    
    func setFilterHighPassCutoff(cutoff: Float) {
        filterNode.highPassBand.frequency = cutoff
    }
    
    func setFilterLowPassCutoff(cutoff: Float) {
        filterNode.lowPassBand.frequency = cutoff
    }
    
    func stop() {
        
        bufferManager.stop()
        playerNode.stop()
        playerNode.reset()
        audioEngine.reset()
        
        playingTrack = nil
        startFrame = nil
    }
    
    // Called when playback of the current track completes
    private func playbackCompleted() {
        
        // Capture the completed track before stopping the player (it will get reset to nil by stop())
        let track = playingTrack!
        stop()
        
        // Publish a notification that playback has completed
        EventRegistry.publishEvent(.PlaybackCompleted, event: PlaybackCompletedEvent(track: track))
    }
    
    func seekToTime(seconds: Double) {
        
        let seekResult = bufferManager.seekToTime(playingTrack!.avFile!, seconds: seconds)
        
        if (seekResult.playbackCompleted) {
            playbackCompleted()
        } else {
            startFrame = seekResult.startFrame!
        }
    }
    
    func getPlayerState() -> SavedPlayerState {
        
        let state: SavedPlayerState = SavedPlayerState()
        
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
        state.pitchBypass = timePitchNode.bypass
        state.pitch = timePitchNode.pitch
        state.pitchOverlap = timePitchNode.overlap
        
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
        state.filterLowPassCutoff = filterNode.lowPassBand.frequency
        state.filterHighPassCutoff = filterNode.highPassBand.frequency
        
        return state
    }
    
    func tearDown() {
        
        // Stop the player and release the audio engine resources
        stop()
        audioEngine.stop()
    }
}