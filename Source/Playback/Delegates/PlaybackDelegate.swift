import Foundation

fileprivate typealias TrackProducer = () -> Track?

/*
    Concrete implementation of PlaybackDelegateProtocol and BasicPlaybackDelegateProtocol.
 */
class PlaybackDelegate: PlaybackDelegateProtocol, PlaylistChangeListenerProtocol, AsyncMessageSubscriber, MessageSubscriber, ActionMessageSubscriber {
    
    // The actual player
    let player: PlayerProtocol
    
    // The actual playback sequence
    let sequencer: SequencerProtocol
    
    // The actual playlist
    let playlist: PlaylistCRUDProtocol
    
    let transcoder: TranscoderProtocol
    
    // User preferences
    let preferences: PlaybackPreferences
    
    var profiles: PlaybackProfiles
    
    var startPlaybackChain: PlaybackChain
    var stopPlaybackChain: PlaybackChain
    var trackPlaybackCompletedChain: PlaybackChain
    
    let chapterPlaybackStartTimeMargin: Double = 0.025
    
    init(_ appState: [PlaybackProfile], _ player: PlayerProtocol, _ sequencer: SequencerProtocol, _ playlist: PlaylistCRUDProtocol, _ transcoder: TranscoderProtocol, _ preferences: PlaybackPreferences) {
        
        self.player = player
        self.sequencer = sequencer
        self.playlist = playlist
        self.transcoder = transcoder
        self.preferences = preferences
        
        self.profiles = PlaybackProfiles()
        
        for profile in appState {
            profiles.add(profile.file, profile)
        }
        
        startPlaybackChain = StartPlaybackChain(player, sequencer, playlist, transcoder, profiles, preferences)
        stopPlaybackChain = StopPlaybackChain(player, sequencer, transcoder, profiles, preferences)
        trackPlaybackCompletedChain = TrackPlaybackCompletedChain(startPlaybackChain as! StartPlaybackChain, stopPlaybackChain as! StopPlaybackChain, sequencer, playlist, profiles, preferences)
        
        // Subscribe to message notifications
        SyncMessenger.subscribe(messageTypes: [.appExitRequest], subscriber: self)
        SyncMessenger.subscribe(actionTypes: [.savePlaybackProfile, .deletePlaybackProfile], subscriber: self)
        AsyncMessenger.subscribe([.playbackCompleted, .transcodingFinished], subscriber: self, dispatchQueue: DispatchQueue.main)
    }
    
    let subscriberId: String = "PlaybackDelegate"
    
    // MARK: play()
    
    func togglePlayPause() {
        
        // Determine current state of player, to then toggle it
        switch state {
            
        case .noTrack:
            
            beginPlayback()
            
        case .paused:
            
            resume()
            
        case .playing:
            
            pause()
            
        case .waiting:
            
            // Skip gap and start playback
            if let track = waitingTrack {
                playImmediately(track)
            }
            
        case .transcoding:
            
            // Do nothing if transcoding
            return
        }
    }
    
    private func beginPlayback() {
        doPlay({return sequencer.begin()}, PlaybackParams.defaultParams(), false)
    }
    
    private func playImmediately(_ track: Track) {
        doPlay({return track}, PlaybackParams().withAllowDelay(false))
    }
    
    func previousTrack() {
        
        if state != .noTrack {
            doPlay({return sequencer.previous()})
        }
    }
    
    func nextTrack() {
        
        if state != .noTrack {
            doPlay({return sequencer.next()})
        }
    }
    
    func play(_ index: Int, _ params: PlaybackParams) {
        doPlay({return sequencer.select(index)}, params)
    }
    
    func play(_ track: Track, _ params: PlaybackParams) {
        doPlay({return sequencer.select(track)}, params)
    }
    
    func play(_ group: Group, _ params: PlaybackParams) {
        doPlay({return sequencer.select(group)}, params)
    }
    
    private func doPlay(_ trackProducer: TrackProducer, _ params: PlaybackParams = PlaybackParams.defaultParams(), _ cancelWaitingOrTranscoding: Bool = true) {
        
        let trackBeforeChange = currentTrack
        let stateBeforeChange = state
        let seekPositionBeforeChange = seekPosition.timeElapsed
        
        let okToPlay = params.interruptPlayback || trackBeforeChange == nil
            
        if okToPlay, let newTrack = trackProducer() {
            
            let requestContext = PlaybackRequestContext.create(stateBeforeChange, trackBeforeChange, seekPositionBeforeChange, newTrack, cancelWaitingOrTranscoding, params)
            
            startPlaybackChain.execute(requestContext)
        }
    }
    
    func stop() {
        
        let trackBeforeChange = currentTrack
        let stateBeforeChange = state
        let seekPositionBeforeChange = seekPosition.timeElapsed
        
        let requestContext = PlaybackRequestContext.create(stateBeforeChange, trackBeforeChange, seekPositionBeforeChange, nil, true, PlaybackParams.defaultParams())
        
        stopPlaybackChain.execute(requestContext)
    }
    
    func trackPlaybackCompleted(_ session: PlaybackSession) {
        
        if PlaybackSession.isCurrent(session) {
            trackPlaybackCompleted()
        }
    }
    
    func trackPlaybackCompleted() {
        
        let trackBeforeChange = currentTrack
        let stateBeforeChange = state
        let seekPositionBeforeChange = seekPosition.timeElapsed
        
        let requestContext = PlaybackRequestContext.create(stateBeforeChange, trackBeforeChange, seekPositionBeforeChange, nil, false, PlaybackParams.defaultParams())
        
        trackPlaybackCompletedChain.execute(requestContext)
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
        return player.toggleLoop()
    }
    
    func cancelTranscoding() {
        
        if let transcodingTrack = playingTrack {
            cancelTranscoding(transcodingTrack)
        }
    }
    
    // MARK: Seeking functions
    
    func seekBackward(_ actionMode: ActionMode = .discrete) {
        attemptSeek(player.seekPosition - getPrimarySeekLength(actionMode))
    }
    
    func seekBackwardSecondary() {
        attemptSeek(player.seekPosition - secondarySeekLength)
    }
    
    func seekForward(_ actionMode: ActionMode = .discrete) {
        attemptSeek(player.seekPosition + getPrimarySeekLength(actionMode))
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
                trackPlaybackCompleted()
            }
        }
    }
    
    /*
        Computes the seek length (i.e. interval/adjustment/delta) used as an increment/decrement when performing a "primary" seek, i.e.
        the seeking that can be performed through the player's seek control buttons.
     
        The "actionMode" parameter denotes whether the seeking is occurring in a discrete (using the main controls) or continuous (through a scroll gesture) mode. The amount of seeking performed
        will vary depending on the mode.
     
        TODO: Clarify how useful this actionMode is, and see if it can be eliminated to prevent confusion.
     */
    private func getPrimarySeekLength(_ actionMode: ActionMode) -> Double {
        
        if actionMode == .discrete {
            
            if preferences.primarySeekLengthOption == .constant {
                
                return Double(preferences.primarySeekLengthConstant)
                
            } else if let trackDuration = playingTrack?.duration {
                
                // Percentage of track duration
                let percentage = Double(preferences.primarySeekLengthPercentage)
                return trackDuration * percentage / 100.0
            }
            
            // Default value
            return 5
            
        } else {
            
            // Continuous seeking
            return preferences.seekLength_continuous
        }
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
                trackPlaybackCompleted()
                
            } else if seekResult.loopRemoved {
                SyncMessenger.publishNotification(PlaybackLoopChangedNotification.instance)
            }
        }
    }
    
    // MARK: Variables that indicate the current player state
    
    var state: PlaybackState {
        return player.state
    }
    
    var seekPosition: (timeElapsed: Double, percentageElapsed: Double, trackDuration: Double) {
        
        if let track = playingTrack {
            
            let elapsedTime: Double = player.seekPosition
            let duration: Double = track.duration
            
            return (elapsedTime, elapsedTime * 100 / duration, duration)
        }
        
        return (0, 0, 0)
    }
    
    var currentTrack: Track? {
        return sequencer.currentTrack
    }
    
    var playingTrack: Track? {
        return state.isPlayingOrPaused ? sequencer.currentTrack : nil
    }
    
    var waitingTrack: Track? {
        return state == .waiting ? sequencer.currentTrack : nil
    }
    
    var transcodingTrack: Track? {
        return state == .transcoding ? sequencer.currentTrack : nil
    }
    
    var playingTrackStartTime: TimeInterval? {
        return player.playingTrackStartTime
    }
    
    var playbackLoop: PlaybackLoop? {
        return player.playbackLoop
    }
    
    private func cancelTranscoding(_ track: Track) {
        
        transcoder.cancel(track)
        stop()
    }
    
    private func savePlaybackProfile() {
        
        if let track = playingTrack {
            profiles.add(track, PlaybackProfile(track.file, seekPosition.timeElapsed))
        }
    }
    
    private func deletePlaybackProfile() {
        
        if let track = playingTrack {
            profiles.remove(track)
        }
    }
    
    private func transcodingFinished(_ msg: TranscodingFinishedAsyncMessage) {
        
        // If transcoding failed, stop playback and send out a notification.
        if !msg.success {
            
            stop()
            
            if let error = msg.track.lazyLoadingInfo.preparationError {
                AsyncMessenger.publishMessage(TrackNotTranscodedAsyncMessage(msg.track, error))
            }
        }
    }
    
    // This function is invoked when the user attempts to exit the app. It checks if there is a track playing and if sound settings for the track need to be remembered.
    private func onExit() -> AppExitResponse {
        
        if preferences.rememberLastPosition, let track = playingTrack,
            preferences.rememberLastPositionOption == .allTracks || profiles.hasFor(track) {
            
            // Remember the current playback settings the next time this track plays. Update the profile with the latest settings applied for this track.
            profiles.add(track, PlaybackProfile(track.file, seekPosition.timeElapsed))
        }
        
        // Proceed with exit
        return AppExitResponse.okToExit
    }
    
    // MARK: Message handling
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if let completionMsg = message as? PlaybackCompletedAsyncMessage {
            
            trackPlaybackCompleted(completionMsg.session)
            return
        }
        
        if let transcodingFinishedMsg = message as? TranscodingFinishedAsyncMessage {
            
            transcodingFinished(transcodingFinishedMsg)
            return
        }
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        case .savePlaybackProfile:
            
            savePlaybackProfile()
            
        case .deletePlaybackProfile:
            
            deletePlaybackProfile()
            
        default: return
            
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        return request is AppExitRequest ? onExit() : EmptyResponse.instance
    }
    
    // ------------------- PlaylistChangeListenerProtocol methods ---------------------
    
    func tracksRemoved(_ removeResults: TrackRemovalResults, _ playingTrackRemoved: Bool, _ removedPlayingTrack: Track?) {
        
        if playingTrackRemoved, let theRemovedPlayingTrack = removedPlayingTrack {
            state == .transcoding ? cancelTranscoding(theRemovedPlayingTrack) : stop()
        }
    }
    
    // Stop playback when the playlist is cleared.
    func playlistCleared() {
        stop()
    }
}
