/*
 Concrete implementation of PlayerProtocol
 */

import Cocoa
import AVFoundation

class Player: PlayerProtocol, AsyncMessageSubscriber {
    
    // The underlying audio graph used to perform playback
    private let graph: PlayerGraphProtocol
    private let playerNode: AVAudioPlayerNode
    
    // Helper used for actual scheduling and playback
    private let scheduler: PlaybackScheduler
    
    private var playbackState: PlaybackState = .noTrack
    
    init(_ graph: PlayerGraphProtocol) {
        
        self.graph = graph
        self.playerNode = graph.playerNode
        self.scheduler = PlaybackScheduler(self.playerNode)
        
        AsyncMessenger.subscribe([.audioOutputChanged], subscriber: self, dispatchQueue: DispatchQueue.main)
    }
    
    // Prepares the player to play a given track
    private func initPlayer(_ track: Track) {
        
        let format = track.playbackInfo!.audioFile!.processingFormat
        
        // Disconnect player and reconnect with the file's processing format
        graph.reconnectPlayerNodeWithFormat(format)
    }
    
    func play(_ track: Track, _ startPosition: Double, _ endPosition: Double? = nil) {
        
        let session = PlaybackSession.start(track)
        
        initPlayer(track)
        
        if let end = endPosition {
            
            // Loop is defined
            session.loop = PlaybackLoop(startPosition, end)
            scheduler.playLoop(session, true)
            
        } else {
            
            scheduler.playTrack(session, startPosition)
        }
        
        playbackState = .playing
    }
    
    func pause() {
        
        scheduler.pause()
        graph.clearSoundTails()
        
        playbackState = .paused
    }
    
    func resume() {
        
        scheduler.resume()
        playbackState = .playing
    }
    
    func stop() {
        
        _ = PlaybackSession.endCurrent()
        
        scheduler.stop()
        playerNode.reset()
        graph.clearSoundTails()
        
        playbackState = .noTrack
    }
    
    func wait() {
        playbackState = .waiting
    }
    
    func seekToTime(_ track: Track, _ seconds: Double) {
        
        let timestamp = PlaybackSession.currentSession!.timestamp
        let loop = PlaybackSession.currentSession!.loop
        
        let session = PlaybackSession.start(track, timestamp)
        session.loop = loop
        
        scheduler.seekToTime(session, seconds, playbackState == .playing)
    }
    
    func getSeekPosition() -> Double {
        
        return playbackState.notPlaying() ? 0 : scheduler.getSeekPosition()
    }
    
    func getPlaybackState() -> PlaybackState {
        return playbackState
    }
    
    var playingTrackStartTime: TimeInterval? {return PlaybackSession.currentSession?.timestamp}
    
    func toggleLoop() -> PlaybackLoop? {
        
        let currentTrackTimeElapsed = getSeekPosition()
        
        let curSession = PlaybackSession.currentSession!
        
        if let curLoop = curSession.loop {
            
            if curLoop.isComplete() {
                
                // Remove loop
                PlaybackSession.removeLoop()
                scheduler.endLoop(curSession, curLoop.endTime!)
                
            } else {
                
                // Mark end
                PlaybackSession.endLoop(currentTrackTimeElapsed)
                
                let oldSession = PlaybackSession.currentSession!
                
                // Seek to loop start
                let track = oldSession.track
                let timestamp = oldSession.timestamp
                let loop = oldSession.loop
                
                let session = PlaybackSession.start(track, timestamp)
                session.loop = loop
                
                scheduler.playLoop(session, playbackState == .playing)
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
    
    var playbackLoop: PlaybackLoop? {return PlaybackSession.getCurrentLoop()}
    
    // MARK: Message handling
    
    func getID() -> String {
        return "Player"
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        // Handler for when the audio output changes (e.g. headphones plugged in/out). Need to restart the audio engine (and resume playback if necessary).
        if let msg = message as? AudioOutputChangedMessage {
            
            let endedSession = msg.endedSession
            
            let playingTrack: Track? = endedSession?.track
            var seekPosn: Double = 0
            
            // Mark the current seek position of the player
            if playingTrack != nil {
                seekPosn = getSeekPosition()
            }
            
            // Restart the audio engine
            graph.restartAudioEngine()
            
            // Resume playback
            if playingTrack != nil {
                
                initPlayer(playingTrack!)
                seekToTime(endedSession!, seekPosn)
            }
        }
    }
    
    // Used only when audio output changes
    private func seekToTime(_ lastSession: PlaybackSession, _ seconds: Double) {
        
        // Hand off old session info to the new session
        let session = PlaybackSession.start(lastSession.track, lastSession.timestamp)
        session.loop = lastSession.loop
        
        scheduler.seekToTime(session, seconds, playbackState == .playing)
    }
    
    func tearDown() {
        stop()
    }
}

// Enumeration of all possible playback states of the player
enum PlaybackState {
    
    case playing
    case paused
    case noTrack
    case waiting
    
    func playingOrPaused() -> Bool {
        return self == .playing || self == .paused
    }
    
    func notPlaying() -> Bool {
        return !playingOrPaused()
    }
}
