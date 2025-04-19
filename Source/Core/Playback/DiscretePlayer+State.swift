//
// DiscretePlayer+State.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

class DiscretePlayer: PlayerProtocol {
    
    let audioGraph: AudioGraphProtocol
    let playerNode: AuralPlayerNode
    let playQueue: PlayQueueProtocol
    
    // Helper used for actual scheduling and playback
    var scheduler: PlaybackSchedulerProtocol!
    
    let avfScheduler: PlaybackSchedulerProtocol
    let ffmpegScheduler: PlaybackSchedulerProtocol
    
    // "Chain of responsibility" chains that are used to perform a sequence of actions when changing tracks
    var startPlaybackChain: StartPlaybackChain!
    var stopPlaybackChain: StopPlaybackChain!
    var trackPlaybackCompletedChain: TrackPlaybackCompletedChain!
    
    var cachedSeekPosition: TimeInterval?
    
    private(set) lazy var messenger = Messenger(for: self)
    
    init(audioGraph: AudioGraphProtocol, playQueue: PlayQueueProtocol) {
        
        self.audioGraph = audioGraph
        self.playerNode = audioGraph.playerNode
        self.playQueue = playQueue
        
        self.avfScheduler = AVFScheduler(playerNode: playerNode)
        self.ffmpegScheduler = FFmpegScheduler(playerNode: playerNode)
        
        self.startPlaybackChain = StartPlaybackChain(playerPlayFunction: self.play(track:params:),
                                                    playerStopFunction: self.stop,
                                                    playQueue: playQueue,
                                                    trackReader: trackReader,
                                                    playbackProfiles,
                                                    preferences.playbackPreferences)
        
        self.stopPlaybackChain = StopPlaybackChain(playerStopFunction: self.stop,
                                                  playQueue: playQueue,
                                                  profiles: playbackProfiles,
                                                  preferences: preferences.playbackPreferences)
        
        self.trackPlaybackCompletedChain = TrackPlaybackCompletedChain(startPlaybackChain, stopPlaybackChain)
    }
    
    // MARK: Variables that indicate the current player state
    
    var state: PlaybackState = .stopped {

        didSet {
            messenger.publish(.Player.playbackStateChanged)
        }
    }
    
    var seekPosition: PlaybackPosition {
        
        guard let track = playingTrack else {return .zero}
        
        let elapsedTime: TimeInterval = playerPosition
        let duration: TimeInterval = track.duration
        
        return PlaybackPosition(timeElapsed: elapsedTime, percentageElapsed: elapsedTime * 100 / duration, trackDuration: duration)
    }
    
    var playerPosition: TimeInterval {
        
        if let seekPos = cachedSeekPosition {return seekPos}
        
        guard state.isPlayingOrPaused, let session = PlaybackSession.currentSession else {return 0}
        
        // Prevent seekPosition from overruning the track duration (or loop start/end times)
        // to prevent weird incorrect UI displays of seek time
            
        // Check for a segment loop
        if let loop = session.loop {
            
            if let loopEndTime = loop.endTime {
                return min(max(loop.startTime, playerNode.seekPosition), loopEndTime)
                
            } else {
                
                // Incomplete loop (start time only)
                return min(max(loop.startTime, playerNode.seekPosition), session.track.duration)
            }
            
        } else {    // No loop
            return min(max(0, playerNode.seekPosition), session.track.duration)
        }
    }
    
    var playingTrack: Track? {
        playQueueDelegate.currentTrack
    }
    
    var hasPlayingTrack: Bool {
        playingTrack != nil
    }
    
    var playingTrackStartTime: TimeInterval? {
        PlaybackSession.currentSession?.timestamp
    }
    
    var playbackLoop: PlaybackLoop? {
        PlaybackSession.currentLoop
    }
    
    var playbackLoopState: PlaybackLoopState {
        
        if let loop = playbackLoop {
            return loop.isComplete ? .complete : .started
        }
        
        return .none
    }
}
