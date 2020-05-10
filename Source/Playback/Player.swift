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
    private let scheduler: PlaybackSchedulerProtocol
    
    var state: PlaybackState = .noTrack
    
    init(_ graph: PlayerGraphProtocol, _ scheduler: PlaybackSchedulerProtocol) {
        
        self.graph = graph
        self.playerNode = graph.playerNode
        self.scheduler = scheduler
        
        AsyncMessenger.subscribe([.audioOutputChanged], subscriber: self, dispatchQueue: DispatchQueue.main)
    }
    
    // Prepares the player to play a given track
    private func initPlayer(_ track: Track) {
        
        let fileFormat = track.playbackInfo!.audioFile!.processingFormat
        
        // Disconnect player and reconnect with the file's processing format
        graph.reconnectPlayerNodeWithFormat(fileFormat)
    }
    
    func play(_ track: Track, _ startPosition: Double, _ endPosition: Double? = nil) {
        
        let session = PlaybackSession.start(track)
        
        initPlayer(track)
        
        if let end = endPosition {
            
            // Loop is defined
            PlaybackSession.defineLoop(startPosition, end)
            scheduler.playLoop(session, true)
            
        } else {
            
            scheduler.playTrack(session, startPosition)
        }
        
        state = .playing
    }
    
    func markLoopAndContinuePlayback(_ loopStartPosition: Double, _ loopEndPosition: Double) {
        
        if let currentSession = PlaybackSession.startNewSessionForPlayingTrack() {

            PlaybackSession.defineLoop(loopStartPosition, loopEndPosition)
            scheduler.playLoop(currentSession, seekPosition, state == .playing)
        }
    }
    
    func pause() {
        
        scheduler.pause()
        graph.clearSoundTails()
        
        state = .paused
    }
    
    func resume() {
        
        scheduler.resume()
        state = .playing
    }
    
    func stop() {
        
        _ = PlaybackSession.endCurrent()
        
        scheduler.stop()
        playerNode.reset()
        graph.clearSoundTails()
        
        state = .noTrack
    }
    
    func wait() {
        state = .waiting
    }
    
    func transcoding() {
        state = .transcoding
    }
    
    func seekToTime(_ track: Track, _ seconds: Double) {
        
        // Create a new identical session (for the track that is playing), and perform a seek within it
        if let curSession = PlaybackSession.startNewSessionForPlayingTrack() {
            scheduler.seekToTime(curSession, seconds, state == .playing)
        }
    }
    
    var seekPosition: Double {
        return state.isNotPlayingOrPaused ? 0 : scheduler.seekPosition
    }
    
    var playingTrackStartTime: TimeInterval? {return PlaybackSession.currentSession?.timestamp}
    
    func toggleLoop() -> PlaybackLoop? {
        
        // Capture the current seek position
        let currentTrackTimeElapsed = seekPosition

        // Make sure that there is a track currently playing.
        if let _ = PlaybackSession.currentSession {
        
            // Check if there currently is a defined loop. If so, create a new identical session.
            if PlaybackSession.hasLoop(), let newSession = PlaybackSession.startNewSessionForPlayingTrack(),
                let curLoop = PlaybackSession.currentLoop {
                
                if let loopEndTime = curLoop.endTime {
                    
                    // Loop has an end time (i.e. is complete) ... remove loop
                    PlaybackSession.removeLoop()
                    scheduler.endLoop(newSession, loopEndTime)
                    
                } else {
                    
                    // Loop has a start time, but no end time ... mark its end time
                    PlaybackSession.endLoop(currentTrackTimeElapsed)
                    scheduler.playLoop(newSession, state == .playing)
                }
                
            } else {
                
                // Loop is currently undefined, mark its start time
                PlaybackSession.beginLoop(currentTrackTimeElapsed)
            }
            
            return PlaybackSession.currentLoop
        }
        
        return nil
    }
    
    func removeLoop() {
        PlaybackSession.removeLoop()
    }
    
    var playbackLoop: PlaybackLoop? {
        return PlaybackSession.currentLoop
    }
    
    // MARK: Message handling
    
    var subscriberId: String {
        return "Player"
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        // Handler for when the audio output changes (e.g. headphones plugged in/out).
        if message is AudioOutputChangedMessage {
            
            audioOutputDeviceChanged()
            return
        }
    }
    
    // When the audio output device changes, restart the audio engine and continue playback as before.
    private func audioOutputDeviceChanged() {
        
        // First, check if a track is playing.
        if let curSession = PlaybackSession.startNewSessionForPlayingTrack() {
            
            // Mark the current seek position
            let curSeekPos = seekPosition
            
            graph.restartAudioEngine()
            
            // Resume playback from the same seek position
            scheduler.seekToTime(curSession, curSeekPos, state == .playing)
            
        } else {
            
            // No track is playing, simply restart the audio engine.
            graph.restartAudioEngine()
        }
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
    case transcoding
    
    var isPlayingOrPaused: Bool {
        return self == .playing || self == .paused
    }
    
    var isNotPlayingOrPaused: Bool {
        return !isPlayingOrPaused
    }
}
