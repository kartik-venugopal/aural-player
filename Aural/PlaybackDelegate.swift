import Foundation

/*
    Concrete implementation of PlaybackDelegateProtocol and BasicPlaybackDelegateProtocol.
 */
class PlaybackDelegate: PlaybackDelegateProtocol, BasicPlaybackDelegateProtocol, PlaylistChangeListenerProtocol, AsyncMessageSubscriber {
    
    // The actual player
    private let player: PlayerProtocol
    
    // The actual playback sequence
    private let playbackSequencer: PlaybackSequencerProtocol
    
    // The actual playlist
    private let playlist: PlaylistAccessorProtocol
    
    // User preferences
    private let preferences: PlaybackPreferences
    
    init(_ player: PlayerProtocol, _ playbackSequencer: PlaybackSequencerProtocol, _ playlist: PlaylistAccessorProtocol, _ preferences: PlaybackPreferences) {
        
        self.player = player
        self.playbackSequencer = playbackSequencer
        self.playlist = playlist
        self.preferences = preferences
        
        // Subscribe to message notifications
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
        return try play(index, 0)
    }
    
    func play(_ index: Int, _ startPosition: Double = 0) throws -> IndexedTrack {
        let track = playbackSequencer.select(index)
        try play(track, startPosition)
        return track
    }
    
    // Throws an error if playback fails
    private func play(_ track: IndexedTrack?, _ startPosition: Double = 0) throws {
        
        // Stop if currently playing
        haltPlayback()
        
        if (track != nil) {
            
            let actualTrack = track!.track
            TrackIO.prepareForPlayback(actualTrack)
            
            if (actualTrack.lazyLoadingInfo.preparationFailed) {
                
                // If an error occurs, playback is halted, and the playback sequence has ended
                playbackSequencer.end()
                
                throw actualTrack.lazyLoadingInfo.preparationError!
            }
            
            player.play(actualTrack, startPosition)
            
            // Notify observers
            AsyncMessenger.publishMessage(TrackPlayedAsyncMessage(track: actualTrack))
        }
    }
    
    // Responds to a notification that playback of the current track has completed. Selects the subsequent track for playback and plays it, notifying observers of the track change.
    private func trackPlaybackCompleted() {
        
        let oldTrack = getPlayingTrack()
        
        // Stop playback of the old track
        haltPlayback()
        
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
        
        // Calculate the new start position
        let curPosn = player.getSeekPosition()
        
        let increment = actionMode == .discrete ? Double(preferences.seekLength) : preferences.seekLength_continuous

        let playingTrack = getPlayingTrack()
        
        if let loop = getPlaybackLoop() {
            
            if let loopEnd = loop.endTime {
            
                // The seek length depends on the action mode
                
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
        if (newPosn < trackDuration) {
            player.seekToTime(playingTrack!.track, newPosn)
        } else {
            trackPlaybackCompleted()
        }
    }
    
    func seekBackward(_ actionMode: ActionMode = .discrete) {
        
        if (player.getPlaybackState() == .noTrack) {
            return
        }
        
        let playingTrack = getPlayingTrack()
        
        // Calculate the new start position
        let curPosn = player.getSeekPosition()
        
        // The seek length depends on the action mode
        let decrement = actionMode == .discrete ? Double(preferences.seekLength) : preferences.seekLength_continuous
        
        if let loop = getPlaybackLoop() {
            
            let loopStart = loop.startTime
            
            let newPosn = max(loopStart, curPosn - decrement)
            player.seekToTime(playingTrack!.track, newPosn)
            
            return
        }
        
        let newPosn = max(0, curPosn - decrement)
        player.seekToTime(playingTrack!.track, newPosn)
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
        if (newPosn < trackDuration) {
            player.seekToTime(playingTrack!.track, newPosn)
        } else {
            trackPlaybackCompleted()
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
        return try play(track, 0)
    }
    
    func play(_ track: Track, _ startPosition: Double = 0) throws -> IndexedTrack {
        
        let indexedTrack = playbackSequencer.select(track)
        try play(indexedTrack, startPosition)
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
    
    func play(_ track: Track, _ startPosition: Double, _ playlistType: PlaylistType) throws -> IndexedTrack {
        
        if (playlistType == .tracks) {
            // Play by index
            let index = playlist.indexOfTrack(track)
            return try play(index!, startPosition)
        }
        
        return try play(track, startPosition)
    }
    
    func play(_ group: Group) throws -> IndexedTrack {
        
        let track = playbackSequencer.select(group)
        try play(track)
        return track
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
    
    // ------------------- PlaylistChangeListenerProtocol methods ---------------------
    
    func tracksRemoved(_ removeResults: TrackRemovalResults, _ playingTrackRemoved: Bool) {
        
        if (playingTrackRemoved) {
            stop()
            AsyncMessenger.publishMessage(TrackChangedAsyncMessage(nil, nil))
        }
    }
    
    func playlistCleared() {
        stop()
        AsyncMessenger.publishMessage(TrackChangedAsyncMessage(nil, nil))
    }
}
