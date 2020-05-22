import Foundation

/*
    Concrete implementation of PlaybackSequencerProtocol. Also implements PlaylistChangeListenerProtocol, to respond to changes in the playlist, and MessageSubscriber to respond to changes in the playlist view.
 */
class PlaybackSequencer: PlaybackSequencerProtocol, PlaylistChangeListenerProtocol, MessageSubscriber, PersistentModelObject {
    
    // The underlying linear sequence of tracks for the current playback scope
    private let sequence: PlaybackSequence
    
    // The current playback scope (See SequenceScope for more details)
    // NOTE - The default sequence scope is "All tracks"
    private let scope: SequenceScope = SequenceScope(.allTracks)
    
    // The current playlist view type selected by the user (this is used to determine the scope)
    private var playlistType: PlaylistType = .tracks
    
    // Used to access the playlist's tracks/groups
    private let playlist: PlaylistAccessorProtocol
    
    // Stores the currently playing track, if there is one
    private(set) var playingTrack: Track?
    
    init(_ playlist: PlaylistAccessorProtocol, _ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode) {
        
        self.sequence = PlaybackSequence(repeatMode, shuffleMode)
        self.playlist = playlist
        
        // Subscribe to notifications that the playlist view type has changed
        SyncMessenger.subscribe(messageTypes: [.playlistTypeChangedNotification], subscriber: self)
    }
    
    var sequenceInfo: (scope: SequenceScope, trackIndex: Int, totalTracks: Int) {
        
        // The sequence cursor is the index of the currently playing track within the current playback sequence
        return (scope, (sequence.curTrackIndex ?? -1) + 1, sequence.size)
    }
    
    func begin() -> Track? {
        
        // Set the scope of the new sequence according to the playlist view type. For ex, if the "Artists" playlist view is selected, the new sequence will consist of all tracks in the "Artists" playlist, and the order of playback will be determined by the ordering within the Artists playlist (in addition to the repeat/shuffle modes).
        
        scope.type = playlistType.toPlaylistScopeType()
        scope.group = nil
        
        // Reset the sequence, with the size of the playlist
        sequence.resizeAndStart(size: playlist.size, withTrackIndex: nil)
        
        // Begin playing the subsequent track (first track determined by the sequence)
        return subsequent()
    }
    
    func end() {
        
        // Reset the sequence cursor (to indicate that no track is playing)
        sequence.end()
        playingTrack = nil
        
        // Reset the scope and the scope type depending on which playlist view is currently selected
        scope.group = nil
        scope.type = playlistType.toPlaylistScopeType()
    }
    
    // MARK: Specific track selection functions -------------------------------------------------------------------------------------
    
    func select(_ index: Int) -> Track? {
        
        // "All tracks" playback scope implied. So, reset the scope to allTracks, and reset the sequence size, if that is not the current scope type
        
        if scope.type != .allTracks {

            scope.type = .allTracks
            scope.group = nil
        }
        
        return startSequence(playlist.size, index)
    }
    
    // Helper function to select a track with a specific index within the current playback sequence
    private func startSequence(_ size: Int, _ cursor: Int) -> Track? {
        
        sequence.resizeAndStart(size: size, withTrackIndex: cursor)
        
        if let track = getTrackForSequenceIndex(cursor) {
            
            playingTrack = track
            return track
        }
        
        return nil
    }
    
    func select(_ track: Track) -> Track? {
        
        if playlistType == .tracks, let index = playlist.indexOfTrack(track) {
            return select(index)
        }
        
        // Get the parent group of the selected track, and set it as the playback scope
        if let scopeType = playlistType.toGroupScopeType(), let groupType = playlistType.toGroupType(),
            let groupInfo = playlist.groupingInfoForTrack(groupType, track) {
            
            scope.type = scopeType
            scope.group = groupInfo.group
            
            // Select the specified track within its parent group, for playback
            return startSequence(groupInfo.group.size, groupInfo.trackIndex)
        }
        
        return nil
    }
    
    func select(_ group: Group) -> Track? {
        
        // Determine the type of the selected track's parent group (which depends on which playlist view type is selected). This will determine the scope type.
        scope.type = group.type.toScopeType()
        
        // Set the scope to the selected group
        scope.group = group
        
        // Reset the sequence based on the group's size
        sequence.resizeAndStart(size: group.size, withTrackIndex: nil)
        
        // Begin playing the subsequent track (first track determined by the sequence)
        return subsequent()
    }
    
    // MARK: Sequence iteration functions -------------------------------------------------------------------------------------
    
    func subsequent() -> Track? {
        
        let subsequent = getTrackForSequenceIndex(sequence.subsequent())
        playingTrack = subsequent
        return subsequent
    }
    
    func next() -> Track? {

        // If there is no next track, don't change the playingTrack variable, because the playing track will continue playing
        if let next = getTrackForSequenceIndex(sequence.next()) {
            
            playingTrack = next
            return next
        }
        
        return nil
    }
    
    func previous() -> Track? {
        
        // If there is no previous track, don't change the playingTrack variable, because the playing track will continue playing
        if let previous = getTrackForSequenceIndex(sequence.previous()) {
            
            playingTrack = previous
            return previous
        }
        
        return nil
    }
    
    func peekSubsequent() -> Track? {
        return getTrackForSequenceIndex(sequence.peekSubsequent())
    }
    
    func peekNext() -> Track? {
        return getTrackForSequenceIndex(sequence.peekNext())
    }
    
    func peekPrevious() -> Track? {
        return getTrackForSequenceIndex(sequence.peekPrevious())
    }
    
    // Helper function that, given the index of a track within the current plyback sequence,
    // returns the corresponding track and its index within the playlist.
    private func getTrackForSequenceIndex(_ sequenceIndex: Int?) -> Track? {
        
        // Unwrap optional cursor value
        if let index = sequenceIndex {
            
            switch scope.type {
                
            // For a single group, the index is the track index within that group
            case .artist, .album, .genre:
                
                if let group = scope.group {
                    return group.trackAtIndex(index)
                }
                
            // For the allTracks scope, the index is the absolute index within the flat playlist
            case .allTracks:
                
                return playlist.trackAtIndex(index)?.track
                
            // For the allArtists, allAlbums, and allGenres scopes, the index is an absolute index that needs to be mapped to a group index and track index within that group.
                
            case .allArtists, .allAlbums, .allGenres:
                
                if let groupType = scope.type.toGroupType() {
                    return getGroupedTrackForAbsoluteIndex(groupType, index)
                }
            }
        }
        
        return nil
    }
    
    /* 
        Given an absolute index within a grouping/hierarchical playlist, maps the absolute index to a group index and track index within that group, and returns the corresponding track at that location.
     
        Example: The track with an absolute index of 5, is Track 0 under Group 2, below.
     
        Group 0
            -> Track 0 (absolute index 0)
            -> Track 1 (absolute index 1)
            -> Track 2 (absolute index 2)
     
        Group 1
            -> Track 0 (absolute index 3)
            -> Track 1 (absolute index 4)
     
        Group 2
            -> Track 0 (absolute index 5)
            -> Track 1 (absolute index 6)
    */
    private func getGroupedTrackForAbsoluteIndex(_ groupType: GroupType, _ absoluteIndex: Int) -> Track {
        
        var groupIndex = 0
        var tracksSoFar = 0
        var trackIndexInGroup = 0
        
        // Iterate over groups while the tracks count (tracksSoFar) is less than the target absolute index
        while tracksSoFar < absoluteIndex {
            
            // Add the size of the current group, to tracksSoFar
            tracksSoFar += playlist.groupAtIndex(groupType, groupIndex).size
            
            // Increment the groupIndex to iterate to the next group
            groupIndex.increment()
        }
        
        // If you've overshot the target index, go back one group, and use the offset to calculate track index within that previous group
        if tracksSoFar > absoluteIndex {
            
            groupIndex.decrement()
            trackIndexInGroup = playlist.groupAtIndex(groupType, groupIndex).size - (tracksSoFar - absoluteIndex)
        }
        
        // Given the groupIndex and trackIndex, retrieve the desired track
        let group = playlist.groupAtIndex(groupType, groupIndex)
        let track = group.trackAtIndex(trackIndexInGroup)
        
        return track
    }
   
    /*
        Does the opposite/inverse of what getGroupedTrackForAbsoluteIndex() does.
        Maps a track within a grouping/hierarchical playlist to its absolute index within that playlist.
     */
    private func getAbsoluteIndexForGroupedTrack(_ groupType: GroupType, _ groupIndex: Int, _ trackIndex: Int) -> Int {
        
        // If we're looking inside the first group, the absolute index is simply the track index
        if groupIndex == 0 {
            return trackIndex
        }
        
        // Iterate over all the groups, noting the size of each group, till the target group is reached
        var absIndexSoFar = 0
        for i in 0..<groupIndex {
            absIndexSoFar += playlist.groupAtIndex(groupType, i).size
        }
        
        // The target group has been reached. Now, simply add the track index to absIndexSoFar, and that is the desired value
        return absIndexSoFar + trackIndex
    }
    
    // MARK: Repeat/Shuffle functions -------------------------------------------------------------------------------------
    
    func setRepeatMode(_ repeatMode: RepeatMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequence.setRepeatMode(repeatMode)
    }
    
    func setShuffleMode(_ shuffleMode: ShuffleMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequence.setShuffleMode(shuffleMode)
    }
    
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequence.toggleRepeatMode()
    }
    
    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequence.toggleShuffleMode()
    }
    
    var repeatAndShuffleModes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequence.repeatAndShuffleModes
    }
    
    // MARK: PlaylistChangeListenerProtocol methods --------------------------------------------------------------
    
    func tracksAdded(_ addResults: [TrackAddResult]) {
        
        guard !addResults.isEmpty else {return}
        
        if let group = scope.group {
            
            // We are only interested in the results matching the scope's group type.
            let filteredResults: [GroupedTrackAddResult?] = addResults.map {$0.groupingPlaylistResults[group.type]}

            // Look for any results matching both the type and name of the scope group.
            // If nothing is found, the scope is unaffected by this playlist add operation.
            if !filteredResults.contains(where: {group == $0?.track.group}) {
                return
            }
        }
        
        updateSequence(true)
    }
    
    func tracksRemoved(_ removeResults: TrackRemovalResults, _ playingTrackRemoved: Bool, _ removedPlayingTrack: Track?) {
        
        // If the playing track was removed, playback is stopped, and the current sequence has ended
        if playingTrackRemoved {
            
            end()
            
        } else {
            
            // Playing track was not removed. If the scope is a group, it might be unaffected.
        
            guard !removeResults.flatPlaylistResults.isEmpty else {return}
            
            if let group = scope.group {
                
                let filteredResults: [ItemRemovalResult]? = removeResults.groupingPlaylistResults[group.type]
                
                // No results for this group type means the scope was unaffected. (Should be impossible)
                if filteredResults == nil {return}
                
                // We are only interested in the results matching the scope's group type.
                // Loop through the results to see if a result for the scope group exists.
                if let theResults = filteredResults,
                    !theResults.contains(where: {group == ($0 as? GroupRemovalResult)?.group || group == ($0 as? GroupedTracksRemovalResult)?.parentGroup}) {
                    
                    return
                }
            }
        }
        
        updateSequence(true)
    }
    
    func tracksReordered(_ moveResults: ItemMoveResults) {
        
        // Only update the sequence if the type of the playlist that was reordered matches the playback sequence scope.
        // In other words, if, for example, the Albums playlist was reordered, that does not affect the Artists playlist.
        guard scope.type.toPlaylistType() == moveResults.playlistType else {return}

        // If the scope is a group, it will only have been affected if any tracks within it were moved.
        // NOTE - A group being moved doesn't affect the playback scope if the scope is limited to that group.
        if let group = scope.group, !moveResults.results.contains(where: {group == ($0 as? TrackMoveResult)?.parentGroup}) {
            return
        }
        
        updateSequence(false)
    }
    
    func playlistSorted(_ sortResults: SortResults) {
        
        // Only update the sequence if the type of the playlist that was sorted matches the playback sequence scope.
        // In other words, if, for example, the Albums playlist was sorted, that does not affect the Artists playlist.
        guard scope.type.toPlaylistType() == sortResults.playlistType else {return}
        
        // If the scope is a group, it will only have been affected if any tracks within it were sorted.
        // NOTE - Groups being sorted doesn't affect the playback scope if the scope is limited to a single group (and no tracks within it were sorted).
        // Check the parent groups of the sorted tracks, and check if the scope group was one of them.
        if let group = scope.group, !sortResults.tracksSorted || !sortResults.affectedParentGroups.contains(group) {
            return
        }
        
        updateSequence(false)
    }
    
    func playlistCleared() {
        
        // The sequence has ended, and needs to be cleared
        sequence.clear()
        end()
    }
    
    // Updates the playback sequence. This function is called in response to changes in the playlist,
    // to update the size of the sequence, and the sequence cursor, both of which may have changed.
    private func updateSequence(_ resize: Bool) {
        
        // No need to update the sequence if no track is playing. It will get updated whenever playback begins.
        guard let playingTrackIndex = calculatePlayingTrackIndex() else {return}
        
        if resize {
            
            // Calculate the new sequence size (either the size of the group scope, if there is one, or of the entire playlist).
            let newSequenceSize: Int = scope.group?.size ?? playlist.size
            newSequenceSize == 0 ? sequence.clear() : sequence.resizeAndStart(size: newSequenceSize, withTrackIndex: playingTrackIndex)
            
        } else {
            
            sequence.start(withTrackIndex: playingTrackIndex)
        }
    }
    
    // Calculates the index of the playing track within the current playback sequence.
    // This function is called in response to changes in the playlist, to update the index which may have changed.
    private func calculatePlayingTrackIndex() -> Int? {
        
        // We only need to do this if there is a track currently playing
        if let playingTrack = playingTrack {
            
            switch scope.type {
                
            case .allArtists, .allAlbums, .allGenres:
                
                // Recalculate the absolute index of the playing track, given its parent group and track index within that group
                
                if let groupType = scope.type.toGroupType(), let groupInfo = playlist.groupingInfoForTrack(groupType, playingTrack) {
                    return getAbsoluteIndexForGroupedTrack(groupType, groupInfo.groupIndex, groupInfo.trackIndex)
                }
                
            case .artist, .album, .genre:
                
                // The index of the playing track within the group is simply its track index
                if let group = scope.group {
                    return group.indexOfTrack(playingTrack)
                }
                
            case .allTracks:
                
                // The index of the playing track within the flat playlist is simply its absolute index
                return playlist.indexOfTrack(playingTrack)
            }
        }
        
        return nil
    }
    
    // MARK: Message handling -----------------------------------------------------------------------------------------------------------------------------
    
    let subscriberId: String = "PlaybackSequencer"
    
    // When the selected playlist view type changes in the UI (i.e. the selected playlist tab changes), this notification is sent out. Here, we make note of the new playlist type, so that the playback scope may be determined from it.
    private func playlistTypeChanged(_ notification: PlaylistTypeChangedNotification) {
        
        // Updates the instance variable playlistType, with the new playlistType value
        self.playlistType = notification.newPlaylistType
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if let playlistTypeChangedMsg = notification as? PlaylistTypeChangedNotification {
            
            playlistTypeChanged(playlistTypeChangedMsg)
            return
        }
    }
    
    var persistentState: PersistentState {
        
        let state = PlaybackSequenceState()
        
        let modes = sequence.repeatAndShuffleModes
        state.repeatMode = modes.repeatMode
        state.shuffleMode = modes.shuffleMode
        
        return state
    }
}
