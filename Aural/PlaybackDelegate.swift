import Foundation

/*
    Concrete implementation of PlaybackDelegateProtocol and BasicPlaybackDelegateProtocol.
 */
class PlaybackDelegate: PlaybackDelegateProtocol, BasicPlaybackDelegateProtocol, PlaylistChangeListenerProtocol, AsyncMessageSubscriber, MessageSubscriber, ActionMessageSubscriber {
    
    // The actual player
    private let player: PlayerProtocol
    
    // The actual playback sequence
    private let playbackSequencer: PlaybackSequencerProtocol
    
    // The actual playlist
    private let playlist: PlaylistAccessorProtocol
    
    private let history: HistoryProtocol
    
    // User preferences
    private let preferences: PlaybackPreferences
    
    private var currentGap: PlaybackGap? = nil
    
    init(_ player: PlayerProtocol, _ playbackSequencer: PlaybackSequencerProtocol, _ playlist: PlaylistAccessorProtocol, _ history: HistoryProtocol, _ preferences: PlaybackPreferences) {
        
        self.player = player
        self.playbackSequencer = playbackSequencer
        self.playlist = playlist
        self.history = history
        self.preferences = preferences
        
        // Subscribe to message notifications
        SyncMessenger.subscribe(messageTypes: [.appExitRequest], subscriber: self)
        SyncMessenger.subscribe(actionTypes: [.savePlaybackProfile, .deletePlaybackProfile], subscriber: self)
        AsyncMessenger.subscribe([.playbackCompleted], subscriber: self, dispatchQueue: DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive))
    }
    
    func getID() -> String {
        return "PlaybackDelegate"
    }
    
    func togglePlayPause() throws -> (playbackState: PlaybackState, playingTrack: IndexedTrack?, trackChanged: Bool) {
        
        var trackChanged = false
        let playbackState = player.getPlaybackState()
        
        // Determine current state of player, to then toggle it
        switch playbackState {
            
        case .noTrack:
            
            if try beginPlayback() != nil {
                trackChanged = true
            }
            
        case .paused: resume()
            
        case .playing: pause()
            
        }
        
        return (getPlaybackState(), getPlayingTrack(), trackChanged)
    }
    
    private func beginPlayback() throws -> IndexedTrack? {
        
        let track = playbackSequencer.begin()
        try play(track)
        return track
    }
    
    // Plays whatever track follows the currently playing track (if there is one). If no track is playing, selects the first track in the playback sequence. Throws an error if playback fails.
    private func subsequentTrack() throws -> IndexedTrack? {
        
        let track = playbackSequencer.subsequent()
        try play(track)
        return track
    }
    
    private func pause() {
        player.pause()
    }
    
    private func resume() {
        player.resume()
    }
    
    func play(_ index: Int) throws -> IndexedTrack {
        
        let track = playbackSequencer.select(index)
        try play(track)
        return track
    }
    
    func play(_ index: Int, _ startPosition: Double, _ endPosition: Double?) throws -> IndexedTrack {

        let track = playbackSequencer.select(index)
        try play(track, startPosition, endPosition)
        return track
    }
    
    func play(_ index: Int, _ interruptPlayback: Bool) throws -> IndexedTrack? {
        
        let playbackState = player.getPlaybackState()
        if (interruptPlayback || playbackState == .noTrack) {
            return try play(index)
        }
        
        return nil
    }
    
    func play(_ track: Track) throws -> IndexedTrack {
        
        let indexedTrack = playbackSequencer.select(track)
        try play(indexedTrack)
        return indexedTrack
    }
    
    func play(_ track: Track, _ startPosition: Double, _ endPosition: Double?) throws -> IndexedTrack {
        
        let indexedTrack = playbackSequencer.select(track)
        try play(indexedTrack, startPosition, endPosition)
        return indexedTrack
    }
    
    func play(_ track: Track, _ playlistType: PlaylistType) throws -> IndexedTrack {
        
        if (playlistType == .tracks) {
            // Play by index
            let index = playlist.indexOfTrack(track)
            return try play(index!)
        }
        
        return try play(track)
    }
    
    func play(_ track: Track, _ startPosition: Double, _ endPosition: Double?, _ playlistType: PlaylistType) throws -> IndexedTrack {
        
        if (playlistType == .tracks) {
            // Play by index
            let index = playlist.indexOfTrack(track)
            return try play(index!, startPosition, endPosition)
        }
        
        return try play(track, startPosition, endPosition)
    }
    
    func play(_ group: Group) throws -> IndexedTrack {
        
        let track = playbackSequencer.select(group)
        try play(track)
        return track
    }
    
    private func play(_ track: IndexedTrack?) throws {
        
        var startPosition: Double = 0
        
        // Check for playback profile
        if preferences.rememberLastPosition {
            
            if let lastTrack = history.mostRecentlyPlayedItem()?.track {
                
                if preferences.rememberLastPositionOption == .allTracks || PlaybackProfiles.profileForTrack(lastTrack) != nil {
                
                    // Update last position for current track
                    let posn = getSeekPosition().timeElapsed
                    PlaybackProfiles.saveProfile(lastTrack, posn)
                }
            }
            
            if (track != nil) {
                
                // Apply playback profile for new track
                if let profile = PlaybackProfiles.profileForTrack(track!.track) {
                    startPosition = profile.lastPosition
                }
            }
        }
        
        try play(track, startPosition)
    }
    
    // ACTUALLY PLAYS THE TRACK
    // Throws an error if playback fails
    private func play(_ track: IndexedTrack?, _ startPosition: Double, _ endPosition: Double? = nil) throws {
        
        // Invalidate the gap, if there is one
        currentGap = nil
        
        // Stop if currently playing
        haltPlayback()
        
        if (track != nil) {
            
            // Check for gap before track
            if let gap = playlist.getGapBeforeTrack(track!.track) {
                
                currentGap = gap
                
                let gapEndTime_dt = DispatchTime.now() + gap.duration
                let gapEndTime: Date = DateUtils.addToDate(Date(), gap.duration)
                
                DispatchQueue.main.asyncAfter(deadline: gapEndTime_dt) {
                    
                    if self.currentGap != nil && self.currentGap == gap {
                        
                        do {
                            
                            try self.doPlay(track, startPosition)
                            // TODO: Need to send out a notification that playback has actually started
                            
                        } catch let error {
                            
                            if (error is InvalidTrackError) {
                                AsyncMessenger.publishMessage(TrackNotPlayedAsyncMessage(track, error as! InvalidTrackError))
                            }
                        }
                    }
                }
                
                AsyncMessenger.publishMessage(PlaybackGapStartedAsyncMessage(gapEndTime, track!.track))
                
            } else {
                
                // Play sync
                try doPlay(track, startPosition)
            }
        }
    }
    
    private func doPlay(_ track: IndexedTrack?, _ startPosition: Double, _ endPosition: Double? = nil) throws {
        
        let actualTrack = track!.track
        TrackIO.prepareForPlayback(actualTrack)
        
        if (actualTrack.lazyLoadingInfo.preparationFailed) {
            
            // If an error occurs, playback is halted, and the playback sequence has ended
            playbackSequencer.end()
            
            throw actualTrack.lazyLoadingInfo.preparationError!
        }
        
        player.play(actualTrack, startPosition, endPosition)
        
        // Notify observers
        AsyncMessenger.publishMessage(TrackPlayedAsyncMessage(track: actualTrack))
    }
    
    func stop() {
        
        haltPlayback()
        playbackSequencer.end()
    }
    
    // Temporarily halts playback
    private func haltPlayback() {
        if (player.getPlaybackState() != .noTrack) {
            player.stop()
        }
    }
    
    func nextTrack() throws -> IndexedTrack? {
        
        let track = playbackSequencer.next()
        
        if (track != nil) {
            try play(track)
        }
        
        return track
    }
    
    func previousTrack() throws -> IndexedTrack? {
        
        let track = playbackSequencer.previous()
        
        if (track != nil) {
            try play(track)
        }
        
        return track
    }
    
    func getPlaybackState() -> PlaybackState {
        return player.getPlaybackState()
    }
    
    func getPlaybackSequenceInfo() -> (scope: SequenceScope, trackIndex: Int, totalTracks: Int) {
        return playbackSequencer.getPlaybackSequenceInfo()
    }
    
    func getSeekPosition() -> (timeElapsed: Double, percentageElapsed: Double, trackDuration: Double) {
        
        let playingTrack = getPlayingTrack()
        let seconds = playingTrack != nil ? player.getSeekPosition() : 0
        
        let duration = playingTrack == nil ? 0 : playingTrack!.track.duration
        let percentage = playingTrack != nil ? seconds * 100 / duration : 0
        
        return (seconds, percentage, duration)
    }
    
    func seekForward(_ actionMode: ActionMode = .discrete) {
        
        if (player.getPlaybackState() == .noTrack) {
            return
        }
        
        doSeekForward(getPrimarySeekLength(actionMode))
    }
    
    func seekForwardSecondary() {
        
        if (player.getPlaybackState() == .noTrack) {
            return
        }
        
        doSeekForward(getSecondarySeekLength())
    }
    
    private func doSeekForward(_ increment: Double) {
        
        // Calculate the new start position
        let curPosn = player.getSeekPosition()
        
        let playingTrack = getPlayingTrack()
        
        if let loop = getPlaybackLoop() {
            
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
        
        if (player.getPlaybackState() == .playing) {
            
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
        
        if (player.getPlaybackState() == .noTrack) {
            return
        }
        
        doSeekBackward(getPrimarySeekLength(actionMode))
    }
    
    func seekBackwardSecondary() {
        
        if (player.getPlaybackState() == .noTrack) {
            return
        }
        
        doSeekBackward(getSecondarySeekLength())
    }
    
    private func doSeekBackward(_ decrement: Double) {
        
        let playingTrack = getPlayingTrack()
        
        // Calculate the new start position
        let curPosn = player.getSeekPosition()
        
        if let loop = getPlaybackLoop() {
            
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
                
                let trackDuration = getPlayingTrack()!.track.duration
                let perc = Double(preferences.primarySeekLengthPercentage)
                
                return trackDuration * perc / 100.0
            }
            
        } else {
            return preferences.seekLength_continuous
        }
    }
    
    private func getSecondarySeekLength() -> Double {
        
        if preferences.secondarySeekLengthOption == .constant {
            
            return Double(preferences.secondarySeekLengthConstant)
            
        } else {
            
            let trackDuration = getPlayingTrack()!.track.duration
            let perc = Double(preferences.secondarySeekLengthPercentage)
            
            return trackDuration * perc / 100.0
        }
    }
    
    func seekToPercentage(_ percentage: Double) {
        
        if (player.getPlaybackState() == .noTrack) {
            return
        }
        
        // Calculate the new start position
        let playingTrack = getPlayingTrack()
        let trackDuration = playingTrack!.track.duration
        
        let newPosn = percentage * trackDuration / 100
        
        // If there's a loop, check where the seek occurred relative to the loop
        if let loop = getPlaybackLoop() {
            
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
        
        if (player.getPlaybackState() == .playing) {
            
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
    
    func seekToTime(_ seconds: Double) {
        
        // Calculate the new start position
        let playingTrack = getPlayingTrack()
        let trackDuration = playingTrack!.track.duration
        
        let percentage = seconds * 100 / trackDuration
        seekToPercentage(percentage)
    }
    
    func getPlayingTrack() -> IndexedTrack? {
        return playbackSequencer.getPlayingTrack()
    }
    
    func getPlayingTrackGroupInfo(_ groupType: GroupType) -> GroupedTrack? {
        
        if let playingTrack = playbackSequencer.getPlayingTrack() {
            return playlist.groupingInfoForTrack(groupType, playingTrack.track)
        }
        
        return nil
    }
    
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return playbackSequencer.toggleRepeatMode()
    }
    
    func setRepeatMode(_ repeatMode: RepeatMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return playbackSequencer.setRepeatMode(repeatMode)
    }
    
    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return playbackSequencer.toggleShuffleMode()
    }
    
    func setShuffleMode(_ shuffleMode: ShuffleMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return playbackSequencer.setShuffleMode(shuffleMode)
    }
    
    func getRepeatAndShuffleModes() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode){
        return playbackSequencer.getRepeatAndShuffleModes()
    }
    
    func toggleLoop() -> PlaybackLoop? {
        return player.toggleLoop()
    }
    
    private func removeLoop() {
        player.removeLoop()
    }
    
    func getPlayingTrackStartTime() -> TimeInterval? {
        return player.getPlayingTrackStartTime()
    }
    
    func getPlaybackLoop() -> PlaybackLoop? {
        return player.getPlaybackLoop()
    }
    
    // Responds to a notification that playback of the current track has completed. Selects the subsequent track for playback and plays it, notifying observers of the track change.
    private func trackPlaybackCompleted() {
        
        let oldTrack = getPlayingTrack()
        
        // Reset playback profile last position to 0 (if there is a profile for the track that completed)
        if PlaybackProfiles.profileForTrack(oldTrack!.track) != nil {
            
            // TODO: This will not work in the future, if the playback profile contains stuff other than just the last position. In that case, mutate the lastPosition variable to 0 but keep the profile otherwise intact
            PlaybackProfiles.deleteProfile(oldTrack!.track)
        }
        
        // Stop playback of the old track
        haltPlayback()
        
        // ----------------- GAP ---------------------
        
        if let gap = playlist.getGapAfterTrack(oldTrack!.track) {

            currentGap = gap
            
            let gapEndTime_dt = DispatchTime.now() + gap.duration
            let gapEndTime: Date = DateUtils.addToDate(Date(), gap.duration)
            
            DispatchQueue.main.asyncAfter(deadline: gapEndTime_dt) {

                if self.currentGap != nil && self.currentGap == gap {
                    
                    self.continuePlayback()
                    
                    // Invalidate the gap
                    self.currentGap = nil
                }
            }
            
            let subsequentTrack = playbackSequencer.peekSubsequent()
            AsyncMessenger.publishMessage(PlaybackGapStartedAsyncMessage(gapEndTime, subsequentTrack?.track))

        } else {
            continuePlayback()
        }
    }
    
    private func continuePlayback() {
        
        let oldTrack = getPlayingTrack()
        
        // Continue the playback sequence
        do {
            
            let newTrack = try subsequentTrack()
            
            // Notify the UI about this track change event
            AsyncMessenger.publishMessage(TrackChangedAsyncMessage(oldTrack, newTrack))
            
        } catch let error {
            
            if (error is InvalidTrackError) {
                AsyncMessenger.publishMessage(TrackNotPlayedAsyncMessage(oldTrack, error as! InvalidTrackError))
            }
        }
    }
    
    private func saveProfile() {
        
        if let plTrack = getPlayingTrack()?.track {
            PlaybackProfiles.saveProfile(plTrack, getSeekPosition().timeElapsed)
        }
    }
    
    private func deleteProfile() {
        
        if let plTrack = getPlayingTrack()?.track {
            PlaybackProfiles.deleteProfile(plTrack)
        }
    }
    
    // This function is invoked when the user attempts to exit the app. It checks if there is a track playing and if sound settings for the track need to be remembered.
    private func onExit() -> AppExitResponse {
        
        if preferences.rememberLastPosition {
            
            // Remember the current playback settings the next time this track plays. Update the profile with the latest settings applied for this track.
            if let plTrack = getPlayingTrack()?.track {
                
                if preferences.rememberLastPositionOption == .allTracks || PlaybackProfiles.profileForTrack(plTrack) != nil {
                    PlaybackProfiles.saveProfile(plTrack, getSeekPosition().timeElapsed)
                }
            }
        }
        
        // No ongoing recording, proceed with exit
        return AppExitResponse.okToExit
    }
    
    // MARK: Message handling
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if (message is PlaybackCompletedAsyncMessage) {
            trackPlaybackCompleted()
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
    
    func tracksRemoved(_ removeResults: TrackRemovalResults, _ playingTrackRemoved: Bool) {
        
        if (playingTrackRemoved) {
            
            currentGap = nil
            stop()
            AsyncMessenger.publishMessage(TrackChangedAsyncMessage(nil, nil))
        }
    }
    
    func playlistCleared() {
        
        currentGap = nil
        stop()
        AsyncMessenger.publishMessage(TrackChangedAsyncMessage(nil, nil))
    }
}
