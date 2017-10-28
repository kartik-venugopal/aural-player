import Foundation

/*
    Concrete implementation of PlaybackDelegateProtocol and BasicPlaybackDelegateProtocol.
 */
class PlaybackDelegate: PlaybackDelegateProtocol, BasicPlaybackDelegateProtocol, PlaylistChangeListener, AsyncMessageSubscriber {
    
    // The actual player
    private let player: PlayerProtocol
    
    // The actual playback sequence
    private let playbackSequencer: PlaybackSequencerProtocol
    
    // The actual playlist
    private let playlist: PlaylistAccessorProtocol
    
    // User preferences
    private let preferences: Preferences
    
    // Serial queue for track prep tasks (to prevent concurrent prepping of the same track which could cause contention)
    private var trackPrepQueue: OperationQueue
    
    init(_ player: PlayerProtocol, _ playbackSequencer: PlaybackSequencerProtocol, _ playlist: PlaylistAccessorProtocol, _ preferences: Preferences) {
        
        self.player = player
        self.playbackSequencer = playbackSequencer
        self.playlist = playlist
        self.preferences = preferences
        
        // Initialize the serial track prep queue
        self.trackPrepQueue = OperationQueue()
        trackPrepQueue.underlyingQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        trackPrepQueue.maxConcurrentOperationCount = 1
        
        // Subscribe to message notifications
        AsyncMessenger.subscribe(AsyncMessageType.playbackCompleted, subscriber: self, dispatchQueue: DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive))
    }
    
    func togglePlayPause() throws -> (playbackState: PlaybackState, playingTrack: IndexedTrack?, trackChanged: Bool) {
        
        var trackChanged = false
        let playbackState = player.getPlaybackState()
        
        // Determine current state of player, to then toggle it
        switch playbackState {
            
        case .noTrack: let playingTrack = try subsequentTrack()
        if (playingTrack != nil) {
            trackChanged = true
        }
            
        case .paused: resume()
            
        case .playing: pause()
            
        }
        
        return (getPlaybackState(), getPlayingTrack(), trackChanged)
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
    
    // Throws an error if playback fails
    private func play(_ track: IndexedTrack?) throws {
        
        // Stop if currently playing
        stop()
        
        if (track != nil) {
            
            let actualTrack = track!.track
            TrackIO.prepareForPlayback(actualTrack)
            
            if (actualTrack.lazyLoadingInfo.preparationFailed) {
                throw actualTrack.lazyLoadingInfo.preparationError!
            }
            
            player.play(actualTrack)
            
            // Prepare next possible tracks for playback
            prepareNextTracksForPlayback()
        }
    }
    
    // Computes which tracks are likely to play next (based on the playback sequence and user actions), and eagerly loads metadata for those tracks in preparation for their future playback. This significantly speeds up playback start time when the track is actually played back.
    private func prepareNextTracksForPlayback() {
        
        // Set of all tracks that need to be prepped
        let prepTracksSet = NSMutableSet()
        
        // The three possible tracks that could play next
        let peekSubsequent = playbackSequencer.peekSubsequent()?.track
        let peekNext = playbackSequencer.peekNext()?.track
        let peekPrevious = playbackSequencer.peekPrevious()?.track
        
        let playingTrack = getPlayingTrack()
        
        // Add each of the three tracks to the set of tracks to be prepped, as long as they're non-nil and not equal to the playing track (which has already been prepped, since it is playing)
        if (peekSubsequent != nil && playingTrack?.track !== peekSubsequent) {
            prepTracksSet.add(peekSubsequent!)
        }
        
        if (peekNext != nil) {
            prepTracksSet.add(peekNext!)
        }
        
        if (peekPrevious != nil) {
            prepTracksSet.add(peekPrevious!)
        }
        
        if (prepTracksSet.count > 0) {
            
            for _track in prepTracksSet {
                
                let track = _track as! Track
                
                // If track has not already been prepped, add a serial async task (to avoid concurrent prepping of the same track by two threads) to the trackPrepQueue
                
                // Async execution is important here, because reading from disk could be expensive and this info is not needed immediately.
                if (!track.lazyLoadingInfo.preparedForPlayback) {
                    
                    let prepOp = BlockOperation(block: {
                        TrackIO.prepareForPlayback(track)
                    })
                    
                    trackPrepQueue.addOperation(prepOp)
                }
            }
        }
    }
    
    // Responds to a notification that playback of the current track has completed. Selects the subsequent track for playback and plays it, notifying observers of the track change.
    private func trackPlaybackCompleted() {
        
        let oldTrack = getPlayingTrack()
        
        // Stop playback of the old track
        stop()
        
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
    
    func stop() {
        
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
    
    func getSeekPosition() -> (timeElapsed: Double, percentageElapsed: Double, trackDuration: Double) {
        
        let playingTrack = getPlayingTrack()
        let seconds = playingTrack != nil ? player.getSeekPosition() : 0
        
        let duration = playingTrack!.track.duration
        let percentage = playingTrack != nil ? seconds * 100 / duration : 0
        
        return (seconds, percentage, duration)
    }
    
    func seekForward() {
        
        if (player.getPlaybackState() != .playing) {
            return
        }
        
        // Calculate the new start position
        let curPosn = player.getSeekPosition()
        
        let playingTrack = getPlayingTrack()
        let trackDuration = playingTrack!.track.duration

        let newPosn = min(trackDuration, curPosn + Double(preferences.seekLength))
        
        // If this seek takes the track to its end, stop playback and proceed to the next track
        if (newPosn < trackDuration) {
            
            let playingTrack = getPlayingTrack()
            player.seekToTime(playingTrack!.track, newPosn)
            
        } else {
            trackPlaybackCompleted()
        }
    }
    
    func seekBackward() {
        
        if (player.getPlaybackState() != .playing) {
            return
        }
        
        // Calculate the new start position
        let curPosn = player.getSeekPosition()
        let newPosn = max(0, curPosn - Double(preferences.seekLength))
        
        let playingTrack = getPlayingTrack()
        player.seekToTime(playingTrack!.track, newPosn)
    }
    
    func seekToPercentage(_ percentage: Double) {
        
        if (player.getPlaybackState() != .playing) {
            return
        }
        
        // Calculate the new start position
        let playingTrack = getPlayingTrack()
        let trackDuration = playingTrack!.track.duration
        
        let newPosn = percentage * trackDuration / 100
        
        // If this seek takes the track to its end, stop playback and proceed to the next track
        if (newPosn < trackDuration) {
            player.seekToTime(playingTrack!.track, newPosn)
        } else {
            trackPlaybackCompleted()
        }
    }
    
    func getPlayingTrack() -> IndexedTrack? {
        return playbackSequencer.getPlayingTrack()
    }
    
    func getPlayingTrackGroupInfo(_ groupType: GroupType) -> GroupedTrack? {
        
        if let playingTrack = playbackSequencer.getPlayingTrack() {
            return playlist.getGroupingInfoForTrack(groupType, playingTrack.track)
        }
        
        return nil
    }
    
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        let modes = playbackSequencer.toggleRepeatMode()
        prepareNextTracksForPlayback()
        return modes
    }
    
    func setRepeatMode(_ repeatMode: RepeatMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        let modes = playbackSequencer.setRepeatMode(repeatMode)
        prepareNextTracksForPlayback()
        return modes
    }
    
    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        let modes = playbackSequencer.toggleShuffleMode()
        prepareNextTracksForPlayback()
        return modes
    }
    
    func setShuffleMode(_ shuffleMode: ShuffleMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        let modes = playbackSequencer.setShuffleMode(shuffleMode)
        prepareNextTracksForPlayback()
        return modes
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if (message is PlaybackCompletedAsyncMessage) {
            trackPlaybackCompleted()
            return
        }
    }
    
    func play(_ index: Int, _ interruptPlayback: Bool) throws -> IndexedTrack? {
    
        let playbackState = player.getPlaybackState()
        if (interruptPlayback || playbackState == .noTrack) {
            return try play(index)
        }
        
        return nil
    }
    
    func play(_ track: Track) throws -> IndexedTrack {
        let index = playlist.indexOfTrack(track)
        
        // Cannot be nil, ok to force unwrap
        return try play(index!)
    }
    
    // ------------------- PlaylistChangeListener methods ---------------------
    // Whenever the playlist is modified, the track prep task needs to be executed, to ensure optimal playback responsiveness.
    
    func trackAdded(_ track: Track) {
        prepareNextTracksForPlayback()
    }
    
    func tracksRemoved(_ removedTrackIndexes: [Int], _ removedTracks: [Track]) {
        if (playlist.size() > 0) {
            prepareNextTracksForPlayback()
        }
    }
    
    func trackReordered(_ oldIndex: Int, _ newIndex: Int) {
        prepareNextTracksForPlayback()
    }
    
    func playlistReordered(_ newCursor: Int?) {
        prepareNextTracksForPlayback()
    }
    
    func playlistCleared() {
    }
}
