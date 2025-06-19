//
// DiscretePlayer+Play.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension DiscretePlayer {
    
    ///
    /// A "producer" (or factory) function that produces an optional Track (used when deciding which track will play next).
    ///
    fileprivate typealias TrackProducer = () -> Track?
    
    func togglePlayPause() {
        
        // Determine current state of player, to then toggle it
        switch state {
            
        case .stopped:
            beginPlayback()
            
        case .paused:
            resume()
            
        case .playing:
            pause()
        }
    }
    
    private func beginPlayback() {
        initiatePlayback(playQueue.start)
    }
    
    func play(trackAtIndex index: Int, params: PlaybackParams) {
        
        initiatePlayback({
            playQueue.select(trackAt: index)
        }, params)
    }
    
    func play(track: Track, params: PlaybackParams) {
        
        initiatePlayback({
            playQueue.selectTrack(track)
        }, params)
    }
    
    func playNow(tracks: [Track], clearQueue: Bool, params: PlaybackParams) -> IndexSet {
        
        let indices = playQueue.enqueueTracks(tracks, clearQueue: clearQueue)
        
        if let trackToPlay = tracks.first {
            play(track: trackToPlay, params: params)
        }
        
        return indices
    }
    
    func autoplay(_ command: AutoplayCommandNotification) {
        
        if command.type == .beginPlayback && state == .stopped {
            beginPlayback()
            
        } else if command.type.equalsOneOf(.playFirstAddedTrack, .playSpecificTrack), let track = command.candidateTrack {
            play(track: track, params: PlaybackParams().withInterruptPlayback(command.interruptPlayback))
        }
    }
    
    func previousTrack() {
        
        if state.isPlayingOrPaused {
            initiatePlayback(playQueue.previous)
        }
    }
    
    func nextTrack() {
        
        if state.isPlayingOrPaused {
            initiatePlayback(playQueue.next)
        }
    }
    
    func resumeShuffleSequence(with track: Track, atPosition position: TimeInterval) {
        
        initiatePlayback({
            playQueue.resumeShuffleSequence(with: track)
        }, .init().withStartAndEndPosition(position))
    }
    
    // Captures the current player state and proceeds with playback according to the playback sequence
    private func initiatePlayback(_ trackProducer: TrackProducer, _ params: PlaybackParams = .defaultParams) {
        
        let trackBeforeChange = playingTrack
        let stateBeforeChange = state
        let seekPositionBeforeChange = playerPosition
        
        let okToPlay = params.interruptPlayback || trackBeforeChange == nil
        
        if okToPlay, let newTrack = trackProducer() {
            
            let requestContext = PlaybackRequestContext(stateBeforeChange, trackBeforeChange, seekPositionBeforeChange, newTrack, requestParams: params)
            startPlaybackChain.execute(requestContext)
        }
    }
    
    func doPlay(track: Track, params: PlaybackParams) {
        
        guard let audioFormat = track.playbackContext?.audioFormat else {
            
            NSLog("Player.play() - Unable to play track \(track.displayName) because no audio format is set in its playback context.")
            return
        }
        
        // Disconnect player from audio graph and reconnect with the file's processing format
//        soundOrch.reconnectPlayerNode(withFormat: audioFormat)
        
        let session = PlaybackSession.start(track)
        self.scheduler = track.isNativelySupported ? avfScheduler : ffmpegScheduler
        
        if let end = params.endPosition {
            
            // Segment loop is defined
            PlaybackSession.defineLoop(params.startPosition ?? 0, end)
            scheduler.playLoop(session, beginPlayback: true)
            
        } else {
            
            // No segment loop
            scheduler.playTrack(session, from: params.startPosition)
        }
        
        state = .playing
    }
    
    func pause() {
        
        scheduler.pause()
//        soundOrch.clearSoundTails()
        
        state = .paused
    }
    
    func resume() {
        
        scheduler.resume()
        state = .playing
    }
    
    func resumeIfPaused() {
        
        if state == .paused {
            resume()
        }
    }
    
    func replay() {
        
        if state.isPlayingOrPaused {
            
            forceSeek(to: 0)
            resumeIfPaused()
        }
    }
    
    func stop() {
        initiateStop()
    }
    
    // theCurrentTrack points to the (precomputed) current track before this stop operation.
    // It is required because sometimes, the sequence will have been cleared before stop() is called,
    // making it impossible to capture the current track before stopping playback.
    // If nil, the current track can be computed normally (by calling playingTrack).
    func initiateStop(_ theCurrentTrack: Track? = nil) {
        
        let stateBeforeChange = state
        
        if stateBeforeChange != .stopped {
            
            let trackBeforeChange = theCurrentTrack ?? playingTrack
            let seekPositionBeforeChange = seekPosition.timeElapsed
            
            let requestContext = PlaybackRequestContext(stateBeforeChange, trackBeforeChange, seekPositionBeforeChange, nil, requestParams: .defaultParams)
            stopPlaybackChain.execute(requestContext)
        }
    }
    
    func doStop() {
        
        PlaybackSession.endCurrent()
        
        scheduler?.stop()
        playerNode.reset()
//        soundOrch.clearSoundTails()
        
        state = .stopped
    }
    
    func trackPlaybackCompleted(_ completedSession: PlaybackSession) {
        
        // If the given session has expired, do not continue playback.
        if PlaybackSession.isCurrent(completedSession) {
            doTrackPlaybackCompleted()
        }
    }
    
    // Continues playback when a track finishes playing.
    func doTrackPlaybackCompleted() {
        
        let trackBeforeChange = playingTrack
        let stateBeforeChange = state
        
        // NOTE - Seek position should always be 0 here because the track finished playing.
        let requestContext = PlaybackRequestContext(stateBeforeChange, trackBeforeChange, 0, nil, requestParams: .defaultParams)
        
        trackPlaybackCompletedChain.execute(requestContext)
    }
    
    // MARK: App file open (from Finder) ------------------------------------------------------
    
    func appReopened(_ notification: AppReopenedNotification) {
        
        // When a duplicate notification is sent, don't autoplay ! Otherwise, always autoplay.
        let openWithAddMode = preferences.playQueuePreferences.openWithAddMode
        let clearQueue: Bool = openWithAddMode == .replace
        
        let notDuplicateNotification = !notification.isDuplicateNotification
        lazy var autoplayAfterOpeningPreference: Bool = preferences.playbackPreferences.autoplay.autoplayAfterOpeningTracks
        lazy var autoplayAfterOpeningOption: AutoplayPlaybackPreferences.AutoplayAfterOpeningOption = preferences.playbackPreferences.autoplay.autoplayAfterOpeningOption
        lazy var playerIsStopped: Bool = player.state.isStopped
        lazy var autoplayPreference: Bool = autoplayAfterOpeningPreference && (autoplayAfterOpeningOption == .always || playerIsStopped)
        let autoplay: Bool = notDuplicateNotification && autoplayPreference
        var autoplayCandidates: [URL]? = nil
        
        var allFilesExistInPQ = true
        var existingFiles: Set<URL> = Set()
        
        for file in notification.filesToOpen {
            
            if playQueue.findTrack(forFile: file) == nil {
                allFilesExistInPQ = false
            } else {
                existingFiles.insert(file)
            }
        }
        
        if allFilesExistInPQ {
            
            if playQueue.shuffleMode == .off {
                
                if autoplay, let firstFile = notification.filesToOpen.first, let track = playQueue.findTrack(forFile: firstFile) {
                    play(track: track)
                }
                
            } else {
                
                if autoplay, let randomFile = notification.filesToOpen.randomElement(), let track = playQueue.findTrack(forFile: randomFile) {
                    play(track: track)
                }
            }
            
            return
        }
        
        // MARK: Need to add at least one file to PQ -----------------------------------------------

        if autoplay, let firstFile = existingFiles.first {

            // Add autoplay candidate
            autoplayCandidates = [firstFile]
        }
        
        playQueue.loadTracks(from: notification.filesToOpen,
                             params: .init(clearQueue: clearQueue, autoplayFirstAddedTrack: autoplay, autoplayCandidates: autoplayCandidates))
    }
    
    // MARK: Gapless ------------------------------------------------------
    
    func beginGaplessPlayback() throws {
        
//        try playQueue.prepareForGaplessPlayback()
//        doBeginGaplessPlayback()
    }
    
    var isInGaplessPlaybackMode: Bool {
        false
    }
}
