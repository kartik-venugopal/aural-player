/*
 Concrete implementation of PlayerProtocol
 */

import Cocoa
import AVFoundation

class NewPlayer: PlayerProtocol {
    
    // The underlying audio graph used to perform playback
    private let graph: PlayerGraphProtocol
    private let playerNode: AVAudioPlayerNode
    
    // Helper used for actual scheduling and playback
    private let playbackScheduler: PlaybackScheduler
    
    private var playbackState: PlaybackState = .noTrack
    
    init(_ graph: PlayerGraphProtocol) {
        
        self.graph = graph
        self.playerNode = graph.playerNode
        self.playbackScheduler = PlaybackScheduler(self.playerNode)
    }
    
    // Prepares the player to play a given track
    private func initPlayer(_ track: Track) {
        
        let format = track.playbackInfo!.audioFile!.processingFormat
        
        // Disconnect player and reconnect with the file's processing format
        graph.reconnectPlayerNodeWithFormat(format)
    }
    
    func play(_ track: Track) {
        
        let session = PlaybackSession.start(track)
        
        initPlayer(track)
        playbackScheduler.playTrack(session)
        
        playbackState = .playing
    }
    
    func play(_ track: Track, _ startPosition: Double) {
        
        let session = PlaybackSession.start(track)
        
        initPlayer(track)
        playbackScheduler.playTrack(session, startPosition)
        
        playbackState = .playing
    }
    
    func pause() {
        
        playbackScheduler.pause()
        graph.clearSoundTails()
        
        playbackState = .paused
    }
    
    func resume() {
        
        playbackScheduler.resume()
        playbackState = .playing
    }
    
    func stop() {
        
        PlaybackSession.endCurrent()
        
        playbackScheduler.stop()
        playerNode.reset()
        graph.clearSoundTails()
        
        playbackState = .noTrack
    }
    
    func seekToTime(_ track: Track, _ seconds: Double) {
        
        let timestamp = PlaybackSession.currentSession!.timestamp
        let loop = PlaybackSession.currentSession!.loop
        
        let session = PlaybackSession.start(track, timestamp)
        session.loop = loop
        
        playbackScheduler.seekToTime(session, seconds, playbackState == .playing)
    }
    
    func getSeekPosition() -> Double {
        
        return playbackState == .noTrack ? 0 : playbackScheduler.getSeekPosition()
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
                playbackScheduler.endLoop(curSession, curLoop.endTime!)
                
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
                
                playbackScheduler.playLoop(session, playbackState == .playing)
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
