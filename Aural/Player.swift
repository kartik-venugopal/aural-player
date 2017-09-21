/*
    Concrete implementation of PlayerProtocol
 */

import Cocoa
import AVFoundation

// TODO: Move PlaybackSession code to BufferManager
class Player: PlayerProtocol {
    
    // The underlying audio graph used to perform playback
    private let graph: PlayerGraphProtocol
    private let playerNode: AVAudioPlayerNode
    
    // Helper used for buffer allocation and playback
    private let bufferManager: BufferManager
    
    // The start frame for the current playback session (used to calculate seek position). Represents the point in the track at which playback began.
    private var startFrame: AVAudioFramePosition?
    
    private var playbackState: PlaybackState = .noTrack
    
    init(_ graph: PlayerGraphProtocol) {
        
        self.graph = graph
        self.playerNode = graph.playerNode
        self.bufferManager = BufferManager(self.playerNode)
    }
    
    // Prepares the player to play a given track
    private func initPlayer(_ track: Track) {
        
        let format = track.playbackInfo!.avFile!.processingFormat
        
        // Disconnect player and reconnect with the file's processing format
        graph.reconnectPlayerNodeWithFormat(format)
    }
    
    func play(_ track: Track) {
        
        let session = PlaybackSession.start(track)
        startFrame = BufferManager.FRAME_ZERO
        
        initPlayer(track)
        bufferManager.play(session)
        
        playbackState = .playing
    }
    
    func pause() {
        
        playerNode.pause()
        graph.clearSoundTails()
        
        playbackState = .paused
    }
    
    func resume() {
        
        playerNode.play()
        playbackState = .playing
    }
    
    func stop() {
        
        PlaybackSession.endCurrent()
        
        bufferManager.stop()
        playerNode.reset()
        graph.clearSoundTails()
        
        startFrame = nil
        playbackState = .noTrack
    }
    
    func seekToTime(_ track: Track, _ seconds: Double) {
        
        let session = PlaybackSession.start(track)
        startFrame = bufferManager.seekToTime(session, seconds)
    }
    
    func getSeekPosition() -> Double {
        
        let nodeTime: AVAudioTime? = playerNode.lastRenderTime
        
        if (nodeTime != nil) {
            
            let playerTime: AVAudioTime? = playerNode.playerTime(forNodeTime: nodeTime!)
            
            if (playerTime != nil) {
                
                let lastFrame = (playerTime?.sampleTime)!
                let seconds: Double = Double(startFrame! + lastFrame) / (playerTime?.sampleRate)!
                
                return seconds
            }
        }
        
        // This should never happen (player is not playing)
        return 0
    }
    
    func getPlaybackState() -> PlaybackState {
        return playbackState
    }
}
