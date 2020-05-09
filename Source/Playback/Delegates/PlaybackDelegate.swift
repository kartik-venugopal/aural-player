import Foundation

/*
    Concrete implementation of PlaybackDelegateProtocol and BasicPlaybackDelegateProtocol.
 */
class PlaybackDelegate: PlaybackDelegateProtocol, PlaylistChangeListenerProtocol, AsyncMessageSubscriber, MessageSubscriber, ActionMessageSubscriber {
    
    // The actual player
    private let player: PlayerProtocol
    
    // The actual playback sequence
    private let sequencer: PlaybackSequencerProtocol
    
    // The actual playlist
    private let playlist: PlaylistCRUDProtocol
    
    private let transcoder: TranscoderProtocol
    
    // User preferences
    private let preferences: PlaybackPreferences
    
    var profiles: PlaybackProfiles
    
    private var pendingPlaybackBlock: (() -> Void) = {}
    
    private let chapterPlaybackStartTimeMargin: Double = 0.025
    
    init(_ appState: [PlaybackProfile], _ player: PlayerProtocol, _ sequencer: PlaybackSequencerProtocol, _ playlist: PlaylistCRUDProtocol, _ transcoder: TranscoderProtocol, _ preferences: PlaybackPreferences) {
        
        self.player = player
        self.sequencer = sequencer
        self.playlist = playlist
        self.transcoder = transcoder
        self.preferences = preferences
        
        self.profiles = PlaybackProfiles()
        appState.forEach({profiles.add($0.file, $0)})
        
        // Subscribe to message notifications
        SyncMessenger.subscribe(messageTypes: [.appExitRequest], subscriber: self)
        SyncMessenger.subscribe(actionTypes: [.savePlaybackProfile, .deletePlaybackProfile], subscriber: self)
        AsyncMessenger.subscribe([.playbackCompleted, .transcodingFinished], subscriber: self, dispatchQueue: DispatchQueue.main)
    }
    
    var subscriberId: String {
        return "PlaybackDelegate"
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
            
        case .waiting:
            
            // Skip gap and start playback
            playImmediately(waitingTrack!)
            
        case .transcoding:
            
            // Do nothing if transcoding
            return
        }
    }
    
    private func playImmediately(_ track: IndexedTrack) {
        
        prepareForTrackChange()
        
        let params = PlaybackParams().withAllowDelay(false)
        forcedTrackChange(track, params)
    }
    
    private func beginPlayback() {
        
        prepareForTrackChange()
        
        if let track = sequencer.begin() {
            prepareAndPlay(track)
        }
    }
    
    private func prepareForTrackChange() {
        
        let isPlayingOrPaused = state.playingOrPaused()
        
        let curTrack = isPlayingOrPaused ? playingTrack : (state == .waiting ? waitingTrack : playingTrack)
        
        // Make note of which track was playing/waiting
        TrackChangeContext.setCurrentState(curTrack, state)
        
        // Save playback profile if needed
        // Don't do this unless the preferences require it and the lastTrack was actually playing/paused
        if preferences.rememberLastPosition && isPlayingOrPaused, let actualTrack = curTrack?.track, preferences.rememberLastPositionOption == .allTracks || profiles.hasFor(actualTrack) {
            
            // Update last position for current track
            let curPosn = seekPosition.timeElapsed
            let trackDuration = actualTrack.duration
            
            // If track finished playing the last time, reset the last position to 0
            let lastPosn = (curPosn >= trackDuration ? 0 : curPosn)
            
            profiles.add(actualTrack, PlaybackProfile(actualTrack.file, lastPosn))
        }
    }
    
    func nextTrack() {
        
        prepareForTrackChange()
        forcedTrackChange(sequencer.next())
    }
    
    func previousTrack() {
        
        prepareForTrackChange()
        forcedTrackChange(sequencer.previous())
    }
    
    // Plays whatever track follows the currently playing track (if there is one). If no track is playing, selects the first track in the playback sequence. Throws an error if playback fails.
    private func subsequentTrack() {
        
        prepareForTrackChange()
        
        if let subsequentTrack = sequencer.subsequent() {
            prepareAndPlay(subsequentTrack)
        }
    }
    
    // MARK: play()
    
    private func forcedTrackChange(_ indexedTrack: IndexedTrack?, _ params: PlaybackParams = PlaybackParams.defaultParams()) {
        
        if state == .transcoding {
            
            // Don't cancel transcoding if same track will play next (but with different params e.g. delay or start position)
            if let trackBeingTranscoded = TrackChangeContext.currentTrack?.track, let newTrack = indexedTrack?.track, trackBeingTranscoded != newTrack {
                transcoder.cancel(trackBeingTranscoded)
            }
            
            pendingPlaybackBlock = {}
        }
        
        if let track = indexedTrack {
            
            PlaybackGapContext.clear()
            prepareAndPlay(track, params)
        }
    }
    
    func play(_ index: Int, _ params: PlaybackParams) {
        
        if okToPlay(params) {
            
            prepareForTrackChange()
            forcedTrackChange(sequencer.select(index), params)
        }
    }
    
    // TODO: If this track is already playing, just do a seek
    func play(_ track: Track, _ params: PlaybackParams) {
        
        if okToPlay(params) {
            
            prepareForTrackChange()
            forcedTrackChange(sequencer.select(track), params)
        }
    }
    
    func play(_ group: Group, _ params: PlaybackParams) {

        if okToPlay(params) {
            
            prepareForTrackChange()
            forcedTrackChange(sequencer.select(group), params)
        }
    }
    
    private func okToPlay(_ params: PlaybackParams) -> Bool {
        return params.interruptPlayback || (playingTrack == nil && waitingTrack == nil)
    }
    
    private func prepareAndPlay(_ indexedTrack: IndexedTrack, _ params: PlaybackParams = PlaybackParams.defaultParams()) {
        
        // Stop if currently playing
        haltPlayback()
        
        // Validate track before attempting to play it
        if let prepError = AudioUtils.validateTrack(indexedTrack.track) {
            
            // Note any error encountered
            indexedTrack.track.lazyLoadingInfo.preparationFailed(prepError)
            
            // Playback is halted, and the playback sequence has ended
            sequencer.end()
            
            // Send out an async error message instead of throwing
            AsyncMessenger.publishMessage(TrackNotPlayedAsyncMessage(TrackChangeContext.currentTrack, prepError))
            return
        }
        
        // Track is valid, OK to proceed
        TrackChangeContext.setNewTrack(indexedTrack)
        
        // Figure out start and end position
        var startPosition: Double? = params.startPosition
        let endPosition: Double? = params.endPosition
        
        // Check for playback profile
        if params.startPosition == nil, preferences.rememberLastPosition, let profile = profiles.get(indexedTrack.track) {
            
            // Apply playback profile for new track
            // Validate the playback profile before applying it
            startPosition = (profile.lastPosition >= indexedTrack.track.duration ? 0 : profile.lastPosition)
        }
        
        if params.allowDelay {
            
            if let delay = params.delay {

                // If an explicit delay is defined, it takes precedence over gaps.
                
                PlaybackGapContext.clear()
                
                let gap = PlaybackGap(delay, .beforeTrack)
                PlaybackGapContext.addGap(gap, indexedTrack)
                
                doPlayWithDelay(indexedTrack.track, delay, startPosition, endPosition)
                return
                
            } else {
                
                // If no explicit delay is defined, check for gaps.
                
                if let gapBefore = playlist.getGapBeforeTrack(indexedTrack.track) {
                    
                    PlaybackGapContext.addGap(gapBefore, indexedTrack)
                    
                    // The explicitly defined gap before the track takes precedence over the implicit gap defined by the playback preferences, so remove the implicit gap
                    PlaybackGapContext.removeImplicitGap()
                }
                
                if PlaybackGapContext.hasGaps() {
                    
                    // Check if those gaps were one-time gaps. If so, delete them
                    let oneTimeGaps = PlaybackGapContext.oneTimeGaps()
                    
                    for gap in oneTimeGaps.keys {
                        playlist.removeGapForTrack(oneTimeGaps[gap]!.track, gap.position)
                    }
                    
                    doPlayWithDelay(indexedTrack.track, PlaybackGapContext.gapLength, startPosition, endPosition)
                    return
                }
            }
        }
        
        // No gaps or delay, play immediately (sync)
        doPlay(indexedTrack.track, startPosition, endPosition)
    }
    
    // Plays the track asynchronously, after the given delay
    private func doPlayWithDelay(_ track: Track, _ delay: Double, _ startPosition: Double? = nil, _ endPosition: Double? = nil) {
        
        let gapContextId = PlaybackGapContext.id
        
        // Mark the current state as "waiting" in between tracks
        player.wait()
        
        let gapEndTime_dt = DispatchTime.now() + delay
        let gapEndTime: Date = DateUtils.addToDate(Date(), delay)
        
        DispatchQueue.main.asyncAfter(deadline: gapEndTime_dt) {
            
            // Perform this check to account for the possibility that the gap has been skipped (e.g. user performs Play or Next/Previous track)
            if PlaybackGapContext.isCurrent(gapContextId) {
                
                // Override the current state of the context, because there was a delay
                TrackChangeContext.setCurrentState(TrackChangeContext.newTrack, .waiting)
                
                self.doPlay(track, startPosition, endPosition)
            }
        }
        
        // Prepare the track for playback ahead of time (esp. transcoding)
        TrackIO.prepareForPlayback(track)
        
        // Let observers know that a playback gap has begun
        AsyncMessenger.publishMessage(PlaybackGapStartedAsyncMessage(gapEndTime, TrackChangeContext.currentTrack, TrackChangeContext.newTrack!))
    }
    
    // Plays the track synchronously and immediately
    private func doPlay(_ track: Track, _ startPosition: Double? = nil, _ endPosition: Double? = nil) {
        
        // Invalidate the gap, if there is one
        PlaybackGapContext.clear()
        
        TrackIO.prepareForPlayback(track)
        
        if (track.lazyLoadingInfo.preparationFailed) {
            
            // If an error occurs, playback is halted, and the playback sequence has ended
            sequencer.end()
            
            // Send out an async error message instead of throwing
            AsyncMessenger.publishMessage(TrackNotPlayedAsyncMessage(TrackChangeContext.currentTrack, track.lazyLoadingInfo.preparationError!))
            return
        }
        
        let playbackBlock = {
            
            SyncMessenger.publishNotification(PreTrackChangeNotification(TrackChangeContext.currentTrack, TrackChangeContext.currentState, TrackChangeContext.newTrack))
            
            self.player.play(track, startPosition ?? 0, endPosition)
            
            // TODO: Can we consolidate these 2 notifications into one ?
            AsyncMessenger.publishMessage(TrackChangeContext.encapsulate())
            
            // Notify observers
            AsyncMessenger.publishMessage(TrackPlayedAsyncMessage(track: track))
        }
        
        if !track.lazyLoadingInfo.preparedForPlayback && track.lazyLoadingInfo.needsTranscoding {
            
            // Defer playback until transcoding finishes
            pendingPlaybackBlock = playbackBlock
            player.transcoding()
            
        } else {
            playbackBlock()
        }
    }
    
    // MARK: Other functions
    
    func replay() {
        
        let isPlayingOrPaused = state.playingOrPaused()
        
        if !isPlayingOrPaused {return}
        
        seekToTime(0)
        if state == .paused {
            resume()
        }
    }
    
    private func pause() {
        player.pause()
    }
    
    private func resume() {
        player.resume()
    }
    
    func stop() {
        
        prepareForTrackChange()
        
        if state == .transcoding {
            
            if let track = playingTrack?.track {
                transcoder.cancel(track)
            }
            pendingPlaybackBlock = {}
        }
        
        TrackChangeContext.setNewTrack(nil)
        pendingPlaybackBlock = {}
        
        PlaybackGapContext.clear()
        haltPlayback()
        sequencer.end()

        AsyncMessenger.publishMessage(TrackChangeContext.encapsulate())
    }
    
    // Temporarily halts playback
    private func haltPlayback() {
        
        if (state != .noTrack) {
            player.stop()
        }
    }
    
    func seekForward(_ actionMode: ActionMode = .discrete) {
        
        if (state.notPlaying()) {
            return
        }
        
        doSeekForward(getPrimarySeekLength(actionMode))
    }
    
    func seekForwardSecondary() {
        
        if (state.notPlaying()) {return}
        
        doSeekForward(secondarySeekLength)
    }
    
    private func doSeekForward(_ increment: Double) {
        
        // Calculate the new start position
        let curPosn = player.seekPosition
        
        if let loop = playbackLoop {
            
            if let loopEnd = loop.endTime {
                
                let newPosn = min(loopEnd, curPosn + increment)
                
                if (newPosn < loopEnd) {
                    player.seekToTime(playingTrack!.track, newPosn)
                } else {
                    // Restart loop
                    player.seekToTime(playingTrack!.track, loop.startTime)
                }
                
                return
            }
        }
        
        let trackDuration = playingTrack!.track.duration
        let newPosn = min(trackDuration, curPosn + increment)
        
        // If this seek takes the track to its end, stop playback and proceed to the next track
        
        if (state == .playing) {
            
            if (newPosn < trackDuration) {
                player.seekToTime(playingTrack!.track, newPosn)
            } else {
                
                // Don't do this if paused
                trackPlaybackCompleted()
            }
            
        } else {
            
            // Paused
            player.seekToTime(playingTrack!.track, min(newPosn, trackDuration))
        }
    }
    
    func seekBackward(_ actionMode: ActionMode = .discrete) {
        
        if state.playingOrPaused() {
            doSeekBackward(getPrimarySeekLength(actionMode))
        }
    }
    
    func seekBackwardSecondary() {
        
        if state.playingOrPaused() {
            doSeekBackward(secondarySeekLength)
        }
    }
    
    private func doSeekBackward(_ decrement: Double) {
        
        // Calculate the new start position
        let curPosn = player.seekPosition
        
        if let loop = playbackLoop {
            
            let loopStart = loop.startTime
            
            let newPosn = max(loopStart, curPosn - decrement)
            player.seekToTime(playingTrack!.track, newPosn)
            
            return
        }
        
        let newPosn = max(0, curPosn - decrement)
        player.seekToTime(playingTrack!.track, newPosn)
    }
    
    private func getPrimarySeekLength(_ actionMode: ActionMode) -> Double {
        
        if actionMode == .discrete {
            
            if preferences.primarySeekLengthOption == .constant {
                
                return Double(preferences.primarySeekLengthConstant)
                
            } else {
                
                let trackDuration = playingTrack!.track.duration
                let perc = Double(preferences.primarySeekLengthPercentage)
                
                return trackDuration * perc / 100.0
            }
            
        } else {
            return preferences.seekLength_continuous
        }
    }
    
    private var secondarySeekLength: Double {
        
        if preferences.secondarySeekLengthOption == .constant {
            
            return Double(preferences.secondarySeekLengthConstant)
            
        } else {
            
            let trackDuration = playingTrack!.track.duration
            let perc = Double(preferences.secondarySeekLengthPercentage)
            
            return trackDuration * perc / 100.0
        }
    }
    
    func seekToPercentage(_ percentage: Double) {
        
        if (state.notPlaying()) {
            return
        }
        
        // Calculate the new start position
        let trackDuration = playingTrack!.track.duration
        let newPosn = percentage * trackDuration / 100
        
        // TODO: Shorten this code block
        // If there's a loop, check where the seek occurred relative to the loop
        if let loop = playbackLoop {
            
            // Check if the loop is complete
            if let loopEnd = loop.endTime {
                
                // If outside loop, remove loop
                if newPosn < loop.startTime || newPosn > loopEnd {
                    removeLoop()
                    SyncMessenger.publishNotification(PlaybackLoopChangedNotification.instance)
                }
                
            } else if newPosn < loop.startTime {
                removeLoop()
                SyncMessenger.publishNotification(PlaybackLoopChangedNotification.instance)
            }
        }
        
        // If this seek takes the track to its end, stop playback and proceed to the next track
        
        if (state == .playing) {
            
            if (newPosn < trackDuration) {
                player.seekToTime(playingTrack!.track, newPosn)
            } else {
                trackPlaybackCompleted()
            }
            
        } else {
            
            // Paused
            player.seekToTime(playingTrack!.track, min(newPosn, trackDuration))
        }
    }
    
    var sequenceInfo: (scope: SequenceScope, trackIndex: Int, totalTracks: Int) {return sequencer.sequenceInfo}
    
    // MARK: Seeking
    
    var state: PlaybackState {return player.state}
    
    var seekPosition: (timeElapsed: Double, percentageElapsed: Double, trackDuration: Double) {
        
        if let track = playingTrack?.track {
            
            let elapsedTime: Double = player.seekPosition
            let duration: Double = track.duration
            
            return (elapsedTime, elapsedTime * 100 / duration, duration)
        }
        
        return (0, 0, 0)
    }
    
    var playingTrack: IndexedTrack? {return state == .waiting ? nil : sequencer.playingTrack}
    
    var waitingTrack: IndexedTrack? {return state == .waiting ? sequencer.playingTrack : nil}
    
    var repeatAndShuffleModes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {return sequencer.repeatAndShuffleModes}
    
    var playingTrackStartTime: TimeInterval? {return player.playingTrackStartTime}
    
    var playbackLoop: PlaybackLoop? {return player.playbackLoop}
    
    func playingTrackGroupInfo(_ groupType: GroupType) -> GroupedTrack? {
        
        if let playingTrack = sequencer.playingTrack {
            return playlist.groupingInfoForTrack(groupType, playingTrack.track)
        }
        
        return nil
    }
    
    func seekToTime(_ seconds: Double) {
        
        // Calculate the new start position
        let trackDuration = playingTrack!.track.duration
        let percentage = seconds * 100 / trackDuration
        seekToPercentage(percentage)
    }
    
    // MARK: Chapter playback functions
    
    func playChapter(_ index: Int) {
        
        // Validate track and index by checking the bounds of the chapters array
        if let track = playingTrack?.track, track.hasChapters, index >= 0 && index < track.chapters.count {
            
            // Find the chapter with the given index and seek to its start time.
            // HACK: Add a little margin to the chapter start time to avoid overlap in chapters (except if the start time is zero).
            let startTime = track.chapters[index].startTime
            seekToTime(startTime + (startTime > 0 ? chapterPlaybackStartTimeMargin : 0))
            
            // Resume playback if paused
            if player.state == .paused {
                player.resume()
            }
        }
    }
    
    func previousChapter() {
        
        if let chapters = playingTrack?.track.chapters, !chapters.isEmpty {
            
            let elapsed = player.seekPosition
            
            for index in 0..<chapters.count {
                
                let chapter = chapters[index]
                
                // We have either reached a chapter containing the elapsed time or
                // we have passed the elapsed time (i.e. within a gap between chapters).
                if chapter.containsTimePosition(elapsed) || (elapsed < chapter.startTime) {
                    
                    // If there is a previous chapter, play it
                    if index > 0 {
                        playChapter(index - 1)
                    }
                    
                    // No previous chapter
                    return
                }
            }
            
            // Elapsed time > all chapter times ... it's a gap at the end
            // i.e. need to play the last chapter
            playChapter(chapters.count - 1)
        }
    }
    
    func nextChapter() {
        
        if let chapters = playingTrack?.track.chapters, !chapters.isEmpty {
                
            let elapsed = player.seekPosition
            
            for index in 0..<chapters.count {
                
                let chapter = chapters[index]
                
                if chapter.containsTimePosition(elapsed) {
                
                    // Play the next chapter if there is one
                    if index < (chapters.count - 1) {
                        playChapter(index + 1)
                    }
                    
                    return
                    
                } else if elapsed < chapter.startTime {
                    
                    // Elapsed time is less than this chapter's lower time bound,
                    // i.e. this chapter is the next chapter
                    
                    playChapter(index)
                    return
                }
            }
        }
    }
    
    func replayChapter() {
        
        if let startTime = playingChapter?.chapter.startTime {
        
            // Seek to current chapter's start time
            seekToTime(startTime + (startTime > 0 ? chapterPlaybackStartTimeMargin : 0))
            
            // Resume playback if paused
            if player.state == .paused {
                player.resume()
            }
        }
    }
    
    func loopChapter() {
        
        if let chapter = playingChapter?.chapter {
            player.markLoopAndContinuePlayback(chapter.startTime, chapter.endTime)
        }
    }
    
    var chapterCount: Int {
        return playingTrack?.track.chapters.count ?? 0
    }
    
    // NOTE - This function needs to be efficient because it is repeatedly called to keep track of the current chapter
    // TODO: One possible optimization - keep track of which chapter is playing (in a variable), and in this function, check
    // against it first. In most cases, that check will produce a quick result. Or, implement a binary search. Or both.
    var playingChapter: IndexedChapter? {
        
        if let track = playingTrack?.track, track.hasChapters {
            
            let elapsed = player.seekPosition
            
            var index: Int = 0
            for chapter in track.chapters {
                
                if chapter.containsTimePosition(elapsed) {
                    
                    // Elapsed time is within this chapter's lower and upper time bounds ... found the chapter.
                    return IndexedChapter(track, chapter, index)
                    
                } else if elapsed < chapter.startTime {
                    
                    // Elapsed time is less than this chapter's lower time bound,
                    // i.e. we have already looked at all chapters up to the elapsed time and not found a match.
                    // Since chapters are sorted, we can assume that this indicates a gap between chapters.
                    return nil
                }
                
                index += 1
            }
        }
        
        return nil
    }
    
    // MARK: Repeat and Shuffle
    
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequencer.toggleRepeatMode()
    }
    
    func setRepeatMode(_ repeatMode: RepeatMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequencer.setRepeatMode(repeatMode)
    }
    
    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequencer.toggleShuffleMode()
    }
    
    func setShuffleMode(_ shuffleMode: ShuffleMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequencer.setShuffleMode(shuffleMode)
    }
    
    func toggleLoop() -> PlaybackLoop? {
        return player.toggleLoop()
    }
    
    func cancelTranscoding() {
        
        transcoder.cancel(playingTrack!.track)
        stop()
    }
    
    private func cancelTranscoding(_ track: Track) {
        
        transcoder.cancel(track)
        stop()
    }
    
    private func removeLoop() {
        player.removeLoop()
    }
    
    // Responds to a notification that playback of the current track has completed. Selects the subsequent track for playback and plays it, notifying observers of the track change.
    private func trackPlaybackCompleted() {
        
        let oldTrack = playingTrack
        
        // Reset playback profile last position to 0 (if there is a profile for the track that completed)
        if let profile = profiles.get(oldTrack!.track) {
            profile.lastPosition = 0
        }
        
        // ----------------- GAP AFTER COMPLETED TRACK ---------------------
        
        if sequencer.peekSubsequent() != nil {
            
            // First, check for an explicit gap defined by the user (takes precedence over implicit gap defined by playback preferences)
            if let gapAfterCompletedTrack = playlist.getGapAfterTrack(oldTrack!.track) {
                
                PlaybackGapContext.addGap(gapAfterCompletedTrack, oldTrack!)
                
            } else if preferences.gapBetweenTracks {
                
                // Check for an implicit gap defined by playback preferences
                
                let gapDuration = Double(preferences.gapBetweenTracksDuration)
                let gap = PlaybackGap(gapDuration, .afterTrack, .implicit)
                
                PlaybackGapContext.addGap(gap, oldTrack!)
            }
            
            // Continue playback
            subsequentTrack()
            
        } else {
            
            // No more tracks to play, end playback
            stop()
        }
    }
    
    private func saveProfile() {
        
        if let plTrack = playingTrack?.track {
            profiles.add(plTrack, PlaybackProfile(plTrack.file, seekPosition.timeElapsed))
        }
    }
    
    private func deleteProfile() {
        
        if let plTrack = playingTrack?.track {
            profiles.remove(plTrack)
        }
    }
    
    private func transcodingFinished(_ msg: TranscodingFinishedAsyncMessage) {
        
        if msg.success {
            
            pendingPlaybackBlock()
            pendingPlaybackBlock = {}
            
        } else {
            
            stop()
            
            // Send out playback error message "transcoding failed"
            AsyncMessenger.publishMessage(TrackNotTranscodedAsyncMessage(msg.track, msg.track.lazyLoadingInfo.preparationError!))
        }
    }
    
    // This function is invoked when the user attempts to exit the app. It checks if there is a track playing and if sound settings for the track need to be remembered.
    private func onExit() -> AppExitResponse {
        
        if preferences.rememberLastPosition {
            
            // Remember the current playback settings the next time this track plays. Update the profile with the latest settings applied for this track.
            if let plTrack = playingTrack?.track {
                
                if preferences.rememberLastPositionOption == .allTracks || profiles.hasFor(plTrack) {
                    profiles.add(plTrack, PlaybackProfile(plTrack.file, seekPosition.timeElapsed))
                }
            }
        }
        
        // Proceed with exit
        return AppExitResponse.okToExit
    }
    
    // MARK: Message handling
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if (message is PlaybackCompletedAsyncMessage) {
            trackPlaybackCompleted()
            return
        }
        
        if (message is TranscodingFinishedAsyncMessage) {
            transcodingFinished(message as! TranscodingFinishedAsyncMessage)
            return
        }
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        case .savePlaybackProfile:
            saveProfile()
            
        case .deletePlaybackProfile:
            deleteProfile()
            
        default: return
            
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        if (request is AppExitRequest) {
            return onExit()
        }
        
        return EmptyResponse.instance
    }
    
    // ------------------- PlaylistChangeListenerProtocol methods ---------------------
    
    func tracksRemoved(_ removeResults: TrackRemovalResults, _ playingTrackRemoved: Bool, _ removedPlayingTrack: Track?) {
        
        if (playingTrackRemoved) {
            
            if state == .transcoding {
                cancelTranscoding(removedPlayingTrack!)
            } else {
                stop()
            }
        }
    }
    
    func playlistCleared() {
        stop()
    }
}
