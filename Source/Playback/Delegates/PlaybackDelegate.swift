//
//  PlaybackDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A "producer" (or factory) function that produces an optional Track (used when deciding which track will play next).
///
fileprivate typealias TrackProducer = () -> Track?

///
/// A delegate that represents the Player.
///
/// Acts as a middleman between the Player UI and the Player, providing a simplified
/// interface / facade for the UI layer to control the Player.
///
/// Translates high-level user commands to low-level Player operations, delegating to
/// the Sequencer to determine the current playback sequence.
/// For example, "Play next track" -> "Play 'track1.mp3'".
///
/// - SeeAlso: `Player`
///
class PlaybackDelegate: PlaybackDelegateProtocol {
    
    // The actual player
    let player: PlayerProtocol
    
    // The playback sequence
    let sequencer: SequencerProtocol
    
    // User preferences
    let preferences: PlaybackPreferences
    
    // Playback settings per track
    let profiles: PlaybackProfiles
    
    // "Chain of responsibility" chains that are used to perform a sequence of actions when changing tracks
    let startPlaybackChain: StartPlaybackChain
    let stopPlaybackChain: StopPlaybackChain
    let trackPlaybackCompletedChain: TrackPlaybackCompletedChain
    
    private(set) lazy var messenger = Messenger(for: self)
    
    init(_ player: PlayerProtocol, _ sequencer: SequencerProtocol, _ profiles: PlaybackProfiles, _ preferences: PlaybackPreferences,
         _ startPlaybackChain: StartPlaybackChain, _ stopPlaybackChain: StopPlaybackChain, _ trackPlaybackCompletedChain: TrackPlaybackCompletedChain) {
        
        self.player = player
        self.sequencer = sequencer
        self.preferences = preferences
        self.profiles = profiles
        
        self.startPlaybackChain = startPlaybackChain
        self.stopPlaybackChain = stopPlaybackChain
        self.trackPlaybackCompletedChain = trackPlaybackCompletedChain
        
        // Subscribe to notifications
        messenger.subscribe(to: .application_willExit, handler: onAppExit)
        messenger.subscribeAsync(to: .player_trackPlaybackCompleted, handler: trackPlaybackCompleted(_:))
        messenger.subscribe(to: .sequencer_playingTrackRemoved, handler: doStop(_:))

        // Commands
        messenger.subscribeAsync(to: .player_autoplay, handler: autoplay(_:))
        messenger.subscribe(to: .player_savePlaybackProfile, handler: savePlaybackProfile)
        messenger.subscribe(to: .player_deletePlaybackProfile, handler: deletePlaybackProfile)
        messenger.subscribe(to: .playlist_currentPlaylistChanged, handler: stop)
    }
    
    // MARK: play()
    
    func autoplay(_ command: AutoplayCommandNotification) {
        
        if command.type == .beginPlayback && state == .noTrack {
            beginPlayback()
            
        } else if command.type == .playSpecificTrack, let track = command.candidateTrack {
            play(track, PlaybackParams().withInterruptPlayback(command.interruptPlayback))
        }
    }
    
    func togglePlayPause() {
        
        // Determine current state of player, to then toggle it
        switch state {
            
        case .noTrack:
            
            beginPlayback()
            
        case .paused:
            
            resume()
            
        case .playing:
            
            pause()
        }
    }
    
    private func beginPlayback() {
        doPlay({sequencer.begin()}, PlaybackParams.defaultParams())
    }
    
    func previousTrack() {
        
        if state != .noTrack {
            doPlay({sequencer.previous()})
        }
    }
    
    func nextTrack() {
        
        if state != .noTrack {
            doPlay({sequencer.next()})
        }
    }
    
    func play(_ index: Int, _ params: PlaybackParams) {
        doPlay({sequencer.select(index)}, params)
    }
    
    func play(_ track: Track, _ params: PlaybackParams) {
        doPlay({sequencer.select(track)}, params)
    }
    
    func play(_ group: Group, _ params: PlaybackParams) {
        doPlay({sequencer.select(group)}, params)
    }
    
    // Captures the current player state and proceeds with playback according to the playback sequence
    private func doPlay(_ trackProducer: TrackProducer, _ params: PlaybackParams = PlaybackParams.defaultParams()) {
        
        // TODO: Optimization: If the requested track is the same as the current track, just do a forced seek.
        
        let trackBeforeChange = playingTrack
        let stateBeforeChange = state
        let seekPositionBeforeChange = seekPosition.timeElapsed
        
        let okToPlay = params.interruptPlayback || trackBeforeChange == nil
            
        if okToPlay, let newTrack = trackProducer() {
            
            let requestContext = PlaybackRequestContext(stateBeforeChange, trackBeforeChange, seekPositionBeforeChange, newTrack, params)
            startPlaybackChain.execute(requestContext)
        }
    }
    
    func stop() {
        doStop()
    }
    
    // theCurrentTrack points to the (precomputed) current track before this stop operation.
    // It is required because sometimes, the sequence will have been cleared before stop() is called,
    // making it impossible to capture the current track before stopping playback.
    // If nil, the current track can be computed normally (by calling playingTrack).
    func doStop(_ theCurrentTrack: Track? = nil) {
        
        let stateBeforeChange = state
        
        if stateBeforeChange != .noTrack {
            
            let trackBeforeChange = theCurrentTrack ?? playingTrack
            let seekPositionBeforeChange = seekPosition.timeElapsed
            
            let requestContext = PlaybackRequestContext(stateBeforeChange, trackBeforeChange, seekPositionBeforeChange, nil, PlaybackParams.defaultParams())
            stopPlaybackChain.execute(requestContext)
        }
    }
    
    // MARK: Other functions
    
    func replay() {
        
        if state.isPlayingOrPaused {
        
            seekToTime(0)
            resumeIfPaused()
        }
    }
    
    private func pause() {
        player.pause()
    }
    
    private func resume() {
        player.resume()
    }
    
    func resumeIfPaused() {
        
        if state == .paused {
            player.resume()
        }
    }
    
    func toggleLoop() -> PlaybackLoop? {
        
        guard state.isPlayingOrPaused else {return nil}
        
        return player.toggleLoop()
    }
    
    // MARK: Seeking functions
    
    func seekBackward(_ inputMode: UserInputMode = .discrete) {
        attemptSeek(player.seekPosition - getPrimarySeekLength(inputMode))
    }
    
    func seekBackwardSecondary() {
        attemptSeek(player.seekPosition - secondarySeekLength)
    }
    
    func seekForward(_ inputMode: UserInputMode = .discrete) {
        attemptSeek(player.seekPosition + getPrimarySeekLength(inputMode))
    }
    
    func seekForwardSecondary() {
        attemptSeek(player.seekPosition + secondarySeekLength)
    }
    
    // An attempted seek cannot seek outside the bounds of a segment loop (if one is defined).
    // It occurs, for instance, when seeking backward/forward.
    private func attemptSeek(_ seekPosn: Double) {
        
        if state.isPlayingOrPaused, let track = playingTrack {
            
            let seekResult = player.attemptSeekToTime(track, seekPosn)
            
            if seekResult.trackPlaybackCompleted {
                doTrackPlaybackCompleted()
            }
        }
    }
    
    /*
        Computes the seek length (i.e. interval/adjustment/delta) used as an increment/decrement when performing a "primary" seek, i.e.
        the seeking that can be performed through the player's seek control buttons.
     
        The "inputMode" parameter denotes whether the seeking is occurring in a discrete (using the main controls) or continuous (through a scroll gesture) mode. The amount of seeking performed
        will vary depending on the mode.
     */
    private func getPrimarySeekLength(_ inputMode: UserInputMode) -> Double {
        
        if inputMode == .discrete {
            
            if preferences.primarySeekLengthOption == .constant {
                
                return Double(preferences.primarySeekLengthConstant)
                
            } else if let trackDuration = playingTrack?.duration {
                
                // Percentage of track duration
                let percentage = Double(preferences.primarySeekLengthPercentage)
                return trackDuration * percentage / 100.0
            }
            
        } else {
            
            // Continuous seeking
            return preferences.seekLength_continuous
        }
        
        // Default value
        return 5
    }
    
    /*
        Computes the seek length (i.e. interval/adjustment/delta) used as an increment/decrement when performing a "secondary" seek, i.e.
        the seeking that can only be performed through the application's menu (or associated keyboard shortcuts). There are no control buttons
        to directly perform secondary seeking.
    */
    private var secondarySeekLength: Double {
        
        if preferences.secondarySeekLengthOption == .constant {
            
            return Double(preferences.secondarySeekLengthConstant)
            
        } else if let trackDuration = playingTrack?.duration {
            
            // Percentage of track duration
            let percentage = Double(preferences.secondarySeekLengthPercentage)
            return trackDuration * percentage / 100.0
        }
        
        // Default value
        return 30
    }
    
    func seekToPercentage(_ percentage: Double) {
        
        if let track = playingTrack {
            forceSeek(percentage * track.duration / 100)
        }
    }
    
    func seekToTime(_ seconds: Double) {
        forceSeek(seconds)
    }
    
    // A forced seek can seek outside the bounds of a segment loop (if one is defined).
    // It occurs, for instance, when clicking on the seek bar, or using the "Jump to time" function.
    private func forceSeek(_ seekPosn: Double) {
        
        if state.isPlayingOrPaused, let track = playingTrack {
            
            let seekResult = player.forceSeekToTime(track, seekPosn)
            
            if seekResult.trackPlaybackCompleted {
                doTrackPlaybackCompleted()
                
            } else if seekResult.loopRemoved {
                messenger.publish(.player_playbackLoopChanged)
            }
        }
    }
    
    // MARK: Variables that indicate the current player state
    
    var state: PlaybackState {player.state}
    
    var seekPosition: PlaybackPosition {
        
        if let track = playingTrack {
            
            let elapsedTime: Double = player.seekPosition
            let duration: Double = track.duration
            
            return PlaybackPosition(timeElapsed: elapsedTime, percentageElapsed: elapsedTime * 100 / duration, trackDuration: duration)
        }
        
        return .zero
    }
    
    var playingTrack: Track? {
        return state.isPlayingOrPaused ? sequencer.currentTrack : nil
    }
    
    var playingTrackStartTime: TimeInterval? {
        return player.playingTrackStartTime
    }
    
    var playbackLoop: PlaybackLoop? {
        return player.playbackLoop
    }
    
    private func savePlaybackProfile() {
        
        if let track = playingTrack {
            profiles[track] = PlaybackProfile(track, seekPosition.timeElapsed)
        }
    }
    
    // Saves playback settings for the current track if required by the preferences and existing profiles.
    private func savePlaybackProfileIfNeeded(_ track: Track, _ position: Double? = nil) {
        
        // Save playback settings if the option either requires saving settings for all tracks, or if
        // the option has been set for this particular playing track.
        if preferences.rememberLastPositionOption == .allTracks || profiles.hasFor(track) {
            
            // Remember the current playback settings the next time this track plays.
            // Update the profile with the latest settings for this track.
            
            // If a specific position has been specified, use it. Otherwise, use the current seek position.
            // NOTE - If the seek position has reached the end of the track, the profile position will be reset to 0.
            let lastPosition = position ?? (seekPosition.timeElapsed >= track.duration ? 0 : seekPosition.timeElapsed)
            profiles[track] = PlaybackProfile(track, lastPosition)
        }
    }
    
    private func deletePlaybackProfile() {
        
        if let track = playingTrack {
            profiles.removeFor(track)
        }
    }
    
    // MARK: Message handling
    
    func trackPlaybackCompleted(_ completedSession: PlaybackSession) {
        
        // If the given session has expired, do not continue playback.
        if PlaybackSession.isCurrent(completedSession) {
            doTrackPlaybackCompleted()
            
        } else {
            
            // If the session has expired, the track completion chain will not execute
            // and the track's profile will not be updated, so ensure that it is.
            // Reset the seek position to 0 since the track completed playback.
            savePlaybackProfileIfNeeded(completedSession.track, 0)
        }
    }
    
    // Continues playback when a track finishes playing.
    func doTrackPlaybackCompleted() {
        
        let trackBeforeChange = playingTrack
        let stateBeforeChange = state
        let seekPositionBeforeChange = seekPosition.timeElapsed
        
        let requestContext = PlaybackRequestContext(stateBeforeChange, trackBeforeChange, seekPositionBeforeChange, nil, PlaybackParams.defaultParams())
        
        trackPlaybackCompletedChain.execute(requestContext)
    }
    
    // This function is invoked when the user attempts to exit the app. It checks if there
    // is a track playing and if playback settings for the track need to be remembered.
    func onAppExit() {
        
        if let track = playingTrack {
            savePlaybackProfileIfNeeded(track)
        }
    }
}
