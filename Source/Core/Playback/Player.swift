////
////  Player.swift
////  Aural
////
////  Copyright © 2025 Kartik Venugopal. All rights reserved.
////
////  This software is licensed under the MIT software license.
////  See the file "LICENSE" in the project root directory for license terms.
////
///*
//    Concrete implementation of PlayerProtocol
// */
//
//import AVFoundation
//
/////
///// The Player, responsible for initiating playback, pause / resume / stop, seeking, and segment looping.
/////
///// - SeeAlso: `PlayerProtocol`
/////
//class Player: PlayerProtocol {
//    
//    // The underlying audio graph used to perform playback
//    let graph: PlayerGraphProtocol
//    private let playerNode: AuralPlayerNode
//    
//    // Helper used for actual scheduling and playback
//    var scheduler: PlaybackSchedulerProtocol!
//    
//    let avfScheduler: PlaybackSchedulerProtocol
//    let ffmpegScheduler: PlaybackSchedulerProtocol
//    
//    private(set) lazy var messenger = Messenger(for: self)
//    
//    var isInGaplessPlaybackMode: Bool = false
//    
//    var state: PlaybackState = .stopped {
//
//        didSet {
//            messenger.publish(.Player.playbackStateChanged)
//        }
//    }
//    
//    init(graph: PlayerGraphProtocol, avfScheduler: PlaybackSchedulerProtocol, ffmpegScheduler: PlaybackSchedulerProtocol) {
//        
//        self.graph = graph
//        self.playerNode = graph.playerNode
//        
//        self.avfScheduler = avfScheduler
//        self.ffmpegScheduler = ffmpegScheduler
//        
//        messenger.subscribeAsync(to: .AudioGraph.outputDeviceChanged, handler: audioOutputDeviceChanged)
//        
//        messenger.subscribeAsync(to: .AudioGraph.preGraphChange, handler: preAudioGraphChange(_:))
//        messenger.subscribeAsync(to: .AudioGraph.graphChanged, handler: audioGraphChanged(_:))
//    }
//    
//    func play(_ track: Track, _ startPosition: Double? = nil, _ endPosition: Double? = nil) {
//        
//        guard let audioFormat = track.playbackContext?.audioFormat else {
//            
//            NSLog("Player.play() - Unable to play track \(track.displayName) because no audio format is set in its playback context.")
//            return
//        }
//        
//        // Disconnect player from audio graph and reconnect with the file's processing format
//        graph.reconnectPlayerNode(withFormat: audioFormat)
//
//        let session = PlaybackSession.start(track)
//        self.scheduler = track.isNativelySupported ? avfScheduler : ffmpegScheduler
//
//        if let end = endPosition {
//
//            // Segment loop is defined
//            PlaybackSession.defineLoop(startPosition ?? 0, end)
//            scheduler.playLoop(session, true)
//
//        } else {
//
//            // No segment loop
//            scheduler.playTrack(session, startPosition)
//        }
//
//        state = .playing
//    }
//    
//    // Attempts to perform a seek to a given seek position, respecting the bounds of a defined segment loop. See doSeekToTime() for more details.
//    func attemptSeekToTime(_ track: Track, _ time: Double) -> PlayerSeekResult {
//        return doSeekToTime(track, time, false)
//    }
//    
//    // Forces a seek to a given seek position, not respecting the bounds of a defined segment loop. i.e. a previously defined segment loop
//    // may be removed as a result of this forced seek. See doSeekToTime() for more details.
//    func forceSeekToTime(_ track: Track, _ time: Double) -> PlayerSeekResult {
//        return doSeekToTime(track, time, true)
//    }
//    
//    /*
//        Attempts to seek to a given track position, checking the validity of the desired seek time. Returns an object encapsulating the result of the seek operation.
//     
//        - Parameter attemptedSeekTime: The desired seek time. May be invalid, i.e. < 0 or > track duration, or outside the bounds of a defined segment loop. If so, it will be adjusted accordingly.
//     
//        - Parameter canSeekOutsideLoop: If set to true, the seek may result in a segment loop being removed, if one was defined prior to the seek. Determines whether or not attemptedSeekTime can be outside the bounds of a segment loop.
//     
//        NOTE - If a seek reaches the end of a track, and the player is playing, track playback completion will be signaled.
//     */
//    private func doSeekToTime(_ track: Track, _ attemptedSeekTime: Double, _ canSeekOutsideLoop: Bool) -> PlayerSeekResult {
//        
//        guard PlaybackSession.hasCurrentSession() else {
//            return PlayerSeekResult(actualSeekPosition: 0, loopRemoved: false, trackPlaybackCompleted: false)
//        }
//            
//        var actualSeekTime: Double = attemptedSeekTime
//        var playbackCompleted: Bool
//        var loopRemoved: Bool = false
//        
//        if let loop = self.playbackLoop, !loop.containsPosition(attemptedSeekTime) {
//            
//            if canSeekOutsideLoop {
//
//                // Seeking outside the loop is allowed, so remove the loop.
//                
//                PlaybackSession.removeLoop()
//                loopRemoved = true
//                
//            } else {
//                
//                // Correct the seek time to within the loop's time bounds
//                
//                if attemptedSeekTime < loop.startTime {
//                    actualSeekTime = loop.startTime
//                    
//                } else if let loopEndTime = loop.endTime, attemptedSeekTime >= loopEndTime {
//                    actualSeekTime = loop.startTime
//                }
//            }
//        }
//        
//        // Check if playback has completed (seek time has crossed the track duration)
//        playbackCompleted = actualSeekTime >= track.duration && state == .playing
//
//        // Correct the seek time to within the track's time bounds
//        actualSeekTime = max(0, min(actualSeekTime, track.duration))
//        
//        // Create a new identical session (for the track that is playing), and perform a seek within it
//        if !playbackCompleted, let newSession = PlaybackSession.startNewSessionForPlayingTrack() {
//            
//            if isInGaplessPlaybackMode {
//                
//                if let currentTrackIndex = playQueueDelegate.currentTrackIndex {
//                    
//                    let otherTracks = currentTrackIndex < (playQueueDelegate.size - 1) ? 
//                    Array(playQueueDelegate.tracks[(currentTrackIndex + 1)..<playQueueDelegate.size]) : []
//                    
//                    scheduler.seekGapless(toTime: actualSeekTime, 
//                                          currentSession: newSession, 
//                                          beginPlayback: state == .playing,
//                                          otherTracksToSchedule: otherTracks)
//                }
//                
//            } else {
//                scheduler.seekToTime(newSession, actualSeekTime, state == .playing)
//            }
//            
//            messenger.publish(.Player.seekPerformed)
//        }
//        
//        return PlayerSeekResult(actualSeekPosition: actualSeekTime, loopRemoved: loopRemoved, trackPlaybackCompleted: playbackCompleted)
//    }
//    
//    var cachedSeekPosition: Double?
//    
//    var seekPosition: Double {
//        
//        if let seekPos = cachedSeekPosition {return seekPos}
//        
//        guard state.isPlayingOrPaused, let session = PlaybackSession.currentSession else {return 0}
//        
//        // Prevent seekPosition from overruning the track duration (or loop start/end times)
//        // to prevent weird incorrect UI displays of seek time
//            
//        // Check for a segment loop
//        if let loop = session.loop {
//            
//            if let loopEndTime = loop.endTime {
//                return min(max(loop.startTime, playerNode.seekPosition), loopEndTime)
//                
//            } else {
//                
//                // Incomplete loop (start time only)
//                return min(max(loop.startTime, playerNode.seekPosition), session.track.duration)
//            }
//            
//        } else {    // No loop
//            return min(max(0, playerNode.seekPosition), session.track.duration)
//        }
//    }
//    
//    func pause() {
//        
//        scheduler.pause()
//        graph.clearSoundTails()
//        
//        state = .paused
//    }
//    
//    func resume() {
//        
//        scheduler.resume()
//        state = .playing
//    }
//    
//    func stop() {
//        
//        _ = PlaybackSession.endCurrent()
//        
//        scheduler?.stop()
//        playerNode.reset()
//        graph.clearSoundTails()
//        
//        state = .stopped
//        isInGaplessPlaybackMode = false
//    }
//    
//    var playingTrackStartTime: TimeInterval? {PlaybackSession.currentSession?.timestamp}
//    
//    // MARK: Message handling
//
//    // When the audio output device changes, restart the audio engine and continue playback as before.
//    func audioOutputDeviceChanged() {
//        
//        // First, check if a track is playing.
//        if let curSession = PlaybackSession.startNewSessionForPlayingTrack() {
//            
//            // Mark the current seek position
//            let curSeekPos = seekPosition
//            
//            // Resume playback from the same seek position
//            scheduler.seekToTime(curSession, curSeekPos, state == .playing)
//        }
//    }
//    
//    func preAudioGraphChange(_ notif: PreAudioGraphChangeNotification) {
//        
//        if let currentSession = PlaybackSession.currentSession {
//            
//            notif.context.playbackSession = currentSession
//            notif.context.isPlaying = state == .playing
//            
//            notif.context.seekPosition = seekPosition
//            cachedSeekPosition = notif.context.seekPosition
//            
//            _ = PlaybackSession.endCurrent()
//            scheduler?.stop()
//        }
//    }
//    
//    // When the audio output device changes, restart the audio engine and continue playback as before.
//    func audioGraphChanged(_ notif: AudioGraphChangedNotification) {
//        
//        // First, check if a track is playing.
//        if let endedSession = notif.context.playbackSession, let seekPosition = notif.context.seekPosition {
//            
//            let newSession = PlaybackSession.duplicateSessionAndMakeCurrent(endedSession)
//            
//            // Resume playback from the same seek position
//            scheduler.seekToTime(newSession, seekPosition, notif.context.isPlaying)
//            cachedSeekPosition = nil
//        }
//    }
//    
//    func tearDown() {
//        stop()
//    }
//}
