/*
    Concrete implementation of PlayerProtocol
 */

import Cocoa
import AVFoundation

// TODO: Move PlaybackSession code to BufferManager ???
class Player: PlayerProtocol {
    
    // The underlying audio graph used to perform playback
    private let graph: PlayerGraphProtocol
    private let playerNode: AVAudioPlayerNode
    
    // Helper used for buffer allocation and playback
    private let bufferManager: BufferManager
    
    private var playbackState: PlaybackState = .noTrack
    
    init(_ graph: PlayerGraphProtocol) {
        
        self.graph = graph
        self.playerNode = graph.playerNode
        self.bufferManager = BufferManager(self.playerNode)
    }
    
    // Prepares the player to play a given track
    private func initPlayer(_ track: Track) {
        
        let format = track.playbackInfo!.audioFile!.processingFormat
        
        // Disconnect player and reconnect with the file's processing format
        graph.reconnectPlayerNodeWithFormat(format)
    }
    
    func play(_ track: Track) {
        play(track, 0)
    }
    
    func play(_ track: Track, _ startPosition: Double) {
        
        let session = PlaybackSession.start(track)
        
        initPlayer(track)
        bufferManager.playTrack(session, startPosition)
        
        playbackState = .playing
    }
    
    func pause() {
        
        bufferManager.pause()
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
        
        playbackState = .noTrack
    }
    
    func seekToTime(_ track: Track, _ seconds: Double) {
        
        let timestamp = PlaybackSession.currentSession!.timestamp
        let loop = PlaybackSession.currentSession!.loop
        
        let session = PlaybackSession.start(track, timestamp)
        session.loop = loop
        
        bufferManager.seekToTime(session, seconds, playbackState == .playing)
    }
    
    func getSeekPosition() -> Double {
        
        return playbackState == .noTrack ? 0 : bufferManager.getSeekPosition()
    }
    
    func getPlaybackState() -> PlaybackState {
        return playbackState
    }
    
    func getPlayingTrackStartTime() -> TimeInterval? {
        return PlaybackSession.currentSession?.timestamp
    }
    
    func toggleLoop() -> PlaybackLoop? {
        
        let currentTrackTimeElapsed = getSeekPosition()
        
        let curSession = PlaybackSession.currentSession!
        
        if let curLoop = curSession.loop {
            
            if curLoop.isComplete() {
                
                // Remove loop
                PlaybackSession.removeLoop()
                bufferManager.endLoopScheduling(curSession)
                
            } else {
                
                // Mark end
                PlaybackSession.endLoop(currentTrackTimeElapsed)
                
                // Seek to loop start
                let track = PlaybackSession.currentSession!.track
                let timestamp = PlaybackSession.currentSession!.timestamp
                let loop = PlaybackSession.currentSession!.loop
                
                let session = PlaybackSession.start(track, timestamp)
                session.loop = loop
                
                bufferManager.playLoop(session)
            }
            
        } else {
            
            // Loop is currently undefined, mark start
            PlaybackSession.beginLoop(currentTrackTimeElapsed)
        }
        
        return curSession.loop
    }
    
    func removeLoop() {
        PlaybackSession.removeLoop()
    }
    
    func getPlaybackLoop() -> PlaybackLoop? {
        return PlaybackSession.getCurrentLoop()
    }
}

// Enumeration of all possible playback states of the player
enum PlaybackState {
    
    case playing
    case paused
    case noTrack
}
