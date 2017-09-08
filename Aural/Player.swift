/*
 Wrapper around AVAudioEngine. Handles all audio-related operations ... playback, effects (DSP), etc. Receives calls from PlayerDelegate to modify settings and perform playback.
 */

import Cocoa
import AVFoundation

class Player: PlayerProtocol {
    
    private var graph: PlayerGraphProtocol
    
    // Buffer allocation
    private var bufferManager: BufferManager
    
    // Current playback position (frame)
    private var startFrame: AVAudioFramePosition?
    
    private var playbackState: PlaybackState = .noTrack
    
    init(_ graph: PlayerGraphProtocol) {
        
        self.graph = graph
        bufferManager = BufferManager(graph.playerNode)
    }
    
    // Prepares the player to play a given track
    private func initPlayer(_ track: Track) {
        
        let format = track.avFile!.processingFormat
        
        // Disconnect player and reconnect with the file's processing format
        graph.reconnectPlayerNodeWithFormat(format)
    }
    
    func play(_ playbackSession: PlaybackSession) {
        
        startFrame = BufferManager.FRAME_ZERO
        initPlayer(playbackSession.track.track!)
        bufferManager.play(playbackSession)
        playbackState = .playing
    }
    
    func pause() {
        graph.playerNode.pause()
        playbackState = .paused
    }
    
    func resume() {
        graph.playerNode.play()
        playbackState = .playing
    }
    
    func stop() {
        
        bufferManager.stop()
        graph.playerNode.reset()
        
        startFrame = nil
        playbackState = .noTrack
    }
    
    func seekToTime(_ playbackSession: PlaybackSession, _ seconds: Double) {
        startFrame = bufferManager.seekToTime(playbackSession, seconds)
    }
    
    // In seconds
    func getSeekPosition() -> Double {
        
        let nodeTime: AVAudioTime? = graph.playerNode.lastRenderTime
        
        if (nodeTime != nil) {
            
            let playerTime: AVAudioTime? = graph.playerNode.playerTime(forNodeTime: nodeTime!)
            
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
