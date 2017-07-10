/*
Wrapper around AVAudioEngine. Handles all audio-related operations ... playback, effects (DSP), etc. Receives calls from AppDelegate to modify settings and perform playback.
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
    
    private let eqNode: AVAudioUnitEQ
    private let timePitchNode: AVAudioUnitTimePitch
    private let reverbNode: AVAudioUnitReverb
    
    // TODO
//    private let delayNode: AVAudioUnitDelay
//    private let distortionNode: AVAudioUnitDistortion
    
    // Helper
    private let audioEngineHelper: AudioEngineHelper
    
    // Sound setting value holders
    private var playerVolume: Float
    private var muted: Bool
    private var reverbPreset: AVAudioUnitReverbPreset?
    
    private var bufferManager: BufferManager
    
    // Currently playing track
    private var playingTrack: Track?
    
    // Current playback position (frame)
    private var startFrame: AVAudioFramePosition?
    
    // Sets up the audio engine
    private init() {
        
        playerNode = AVAudioPlayerNode()
        playerNode.volume = PlayerDefaults.volume
        playerNode.pan = PlayerDefaults.balance
        playerVolume = playerNode.volume
        
        muted = PlayerDefaults.muted
        
        audioEngine = AVAudioEngine()
        mainMixer = audioEngine.mainMixerNode
        eqNode = AVAudioUnitEQ(numberOfBands: 10)
        timePitchNode = AVAudioUnitTimePitch()
        reverbNode = AVAudioUnitReverb()
        auxMixer = AVAudioMixerNode()
        
        //        delayNode = AVAudioUnitDelay()
        //        distortionNode = AVAudioUnitDistortion()
        
        timePitchNode.pitch = PlayerDefaults.pitch
        reverbPreset = PlayerDefaults.reverbPreset
        reverbNode.wetDryMix = PlayerDefaults.reverbAmount
        reverbNode.bypass = true
        eqNode.globalGain = PlayerDefaults.eqGlobalGain
        
//        delayNode.wetDryMix = PlayerDefaults.delayAmount
        
        audioEngineHelper = AudioEngineHelper(engine: audioEngine)
        
        audioEngineHelper.addNodes([playerNode, auxMixer, eqNode, timePitchNode, reverbNode])
        audioEngineHelper.connectNodes()
        audioEngineHelper.prepareAndStart()
        
        bufferManager = BufferManager(playerNode: playerNode)
        
        // Register self as a publisher of playback completion events
        EventRegistry.registerPublisher(.PlaybackCompleted, publisher: self)
    }
    
    func loadPlayerState(state: SavedPlayerState) {
        
        playerVolume = state.volume
        muted = state.muted
        
        if (muted) {
            playerNode.volume = 0
        } else {
            playerNode.volume = playerVolume
        }
        
        playerNode.pan = state.balance
        
        setPitch(state.pitch)
        setPitchOverlap(state.pitchOverlap)
        
        setReverb(state.reverb)
        setReverbAmount(state.reverbAmount)
        
        var ctr = 0
        for (freq,gain) in state.eqBands {
            setEQParam(eqNode.bands[ctr++], freq: Float(freq), gain: gain)
        }
        eqNode.globalGain = state.eqGlobalGain
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
    
    // Helper function to set parameters of an EQ band
    private func setEQParam(band: AVAudioUnitEQFilterParameters, freq: Float, gain: Float) {
        
        band.frequency = freq
        band.gain = gain
        
        // Constant
        band.bypass = false
        band.filterType = AVAudioUnitEQFilterType.Parametric
        band.bandwidth = 0.5
    }
    
    func setEQGlobalGain(gain: Float) {
        eqNode.globalGain = gain
    }
    
    func setEQBand(freq: Int , gain: Float) {
        getEQBandParamsForFrequency(freq)!.gain = gain
    }
    
    func setEQBands(bands: [Int: Float]) {
        for (freq, gain) in bands {
            getEQBandParamsForFrequency(freq)!.gain = gain
        }
    }
    
    // Helper function to retrieve EQ band params for a given frequency
    private func getEQBandParamsForFrequency(freq: Int) -> AVAudioUnitEQFilterParameters? {
        
        for band in eqNode.bands {
            if Int(band.frequency) == freq {
                return band
            }
        }
        
        return nil
    }
    
    func getEQBandForFrequency(freq: Int) -> Float {
        
        for band in eqNode.bands {
            if Int(band.frequency) == freq {
                return band.gain
            }
        }
        
        return 0
    }
    
    func setPitch(pitch: Float) {
        timePitchNode.pitch = pitch
    }
    
    func setPitchOverlap(overlap: Float) {
        timePitchNode.overlap = overlap
    }
    
    func setReverb(preset: ReverbPresets) {
        
        let avPreset: AVAudioUnitReverbPreset? = preset.avPreset
        reverbPreset = avPreset
        
        if (avPreset != nil) {
            reverbNode.bypass = false
            reverbNode.loadFactoryPreset(reverbPreset!)
        } else {
            reverbNode.bypass = true
        }
    }
    
    func setReverbAmount(amount: Float) {
        reverbNode.wetDryMix = amount
    }
    
    func setDelayAmount(amount: Float) {
        // Not implemented, for now
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
        
        // Read volume, pan (balance), and repeat and shuffle modes
        state.volume = playerVolume
        state.muted = muted
        state.balance = playerNode.pan
        
        // Read eq bands
        for band in eqNode.bands {
            state.eqBands[Int(band.frequency)] = band.gain
        }
        state.eqGlobalGain = eqNode.globalGain
        
        // Pitch and reverb
        state.pitch = timePitchNode.pitch
        state.pitchOverlap = timePitchNode.overlap
        
        state.reverb = ReverbPresets.mapFromAVPreset(reverbPreset)
        state.reverbAmount = reverbNode.wetDryMix
        
        return state
    }
    
    func tearDown() {
        
        // Stop the player and release the audio engine resources
        stop()
        audioEngine.stop()
    }
}