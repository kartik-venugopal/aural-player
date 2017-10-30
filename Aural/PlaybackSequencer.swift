import Foundation

class PlaybackSequencer: PlaybackSequencerProtocol, PlaylistChangeListener, MessageSubscriber {
    
    private var sequence: PlaybackSequence
    private var scope: SequenceScope = SequenceScope(.allTracks)
    private var playlistType: PlaylistType = .tracks
    
    private var playlist: PlaylistAccessorProtocol
    
    init(_ playlist: PlaylistAccessorProtocol, _ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode) {
        
        self.sequence = PlaybackSequence(0, repeatMode, shuffleMode)
        self.playlist = playlist
        
        SyncMessenger.subscribe(.playlistTypeChangedNotification, subscriber: self)
    }
    
    func getPlaybackSequenceInfo() -> (scope: SequenceScope, trackIndex: Int, totalTracks: Int) {
        return (scope, (sequence.getCursor() ?? -1) + 1, sequence.size())
    }
    
    // No track is currently playing
    func begin() -> IndexedTrack? {
        
        // Set the scope according to playlist type
        
        var type: SequenceScopes
        
        switch playlistType {
            
        case .albums: type = .allAlbums
            
        case .artists: type = .allArtists
            
        case .genres: type = .allGenres
            
        case .tracks: type = .allTracks
            
        }
        
        scope.type = type
        
        // Reset the sequence and begin playing
        sequence.reset(tracksCount: playlist.size())
        
        return subsequent()
    }
    
    func peekSubsequent() -> IndexedTrack? {
        return getTrackForIndex(sequence.peekSubsequent())
    }
    
    func subsequent() -> IndexedTrack? {
        return getTrackForIndex(sequence.subsequent())
    }
    
    func peekNext() -> IndexedTrack? {
        return getTrackForIndex(sequence.peekNext())
    }
    
    func next() -> IndexedTrack? {
        return getTrackForIndex(sequence.next())
    }
    
    func peekPrevious() -> IndexedTrack? {
        return getTrackForIndex(sequence.peekPrevious())
    }
    
    func previous() -> IndexedTrack? {
        return getTrackForIndex(sequence.previous())
    }
    
    func select(_ index: Int) -> IndexedTrack {
        
        if (scope.type != .allTracks) {
            
            // Need to reset the scope and sequence
            scope.type = .allTracks
            sequence.reset(tracksCount: playlist.size())
        }
        
        return doSelectIndex(index)
    }
    
    private func doSelectIndex(_ index: Int) -> IndexedTrack {
        
        sequence.select(index)
        return getTrackForIndex(index)!
    }
    
    func select(_ track: Track) -> IndexedTrack {
        
        var groupType: GroupType
        
        switch playlistType {
            
        case .albums:
            
            scope.type = .album
            groupType = .album
            
        case .artists:
            
            scope.type = .artist
            groupType = .artist
            
        case .genres:
            
            scope.type = .genre
            groupType = .genre
            
        case .tracks:
            
            return select(playlist.indexOfTrack(track)!)
        }
        
        let groupInfo = playlist.getGroupingInfoForTrack(groupType, track)
        let group = groupInfo.group
        scope.scope = group
        sequence.reset(tracksCount: group.size())
        
        return doSelectIndex(groupInfo.trackIndex)
    }
    
    func select(_ group: Group) -> IndexedTrack {
        
        switch playlistType {
            
        case .albums: scope.type = .album
            
        case .artists: scope.type = .artist
            
        case .genres: scope.type = .genre
            
        // This case is impossible (group cannot be selected in tracks view)
        case .tracks: scope.type = scope.type
            
        }
        
        scope.scope = group
        sequence.reset(tracksCount: group.size())
        sequence.resetCursor()
        
        return subsequent()!
    }
    
    func getPlayingTrack() -> IndexedTrack? {
        return getTrackForIndex(sequence.getCursor())
    }
    
    private func getTrackForIndex(_ optionalIndex: Int?) -> IndexedTrack? {
        
        // Unwrap optional cursor value
        if let index = optionalIndex {
            
            switch scope.type {
                
            case .album: return wrapTrack(scope.scope!.trackAtIndex(index))
                
            case .artist: return wrapTrack(scope.scope!.trackAtIndex(index))
                
            case .genre: return wrapTrack(scope.scope!.trackAtIndex(index))
                
            case .allTracks: return playlist.peekTrackAt(index)
                
            case .allArtists: return wrapTrack(getGroupedTrackForAbsoluteIndex(.artist, index))
                
            case .allAlbums: return wrapTrack(getGroupedTrackForAbsoluteIndex(.album, index))
                
            case .allGenres: return wrapTrack(getGroupedTrackForAbsoluteIndex(.genre, index))
                
            }
        }
        
        return nil
    }
    
    private func getGroupedTrackForAbsoluteIndex(_ groupType: GroupType, _ index: Int) -> Track {
        
        var groupIndex = 0
        var tracks = 0
        var trackIndexInGroup = 0
        
        while (tracks < index) {
            tracks += playlist.getGroupAt(groupType, groupIndex).size()
            groupIndex += 1
        }
        
        // If you've overshot the target index, go back one group, and use the offset to calculate track index within that previous group
        if (tracks > index) {
            groupIndex -= 1
            trackIndexInGroup = playlist.getGroupAt(groupType, groupIndex).size() - (tracks - index)
        }
        
        let group = playlist.getGroupAt(groupType, groupIndex)
        let track = group.trackAtIndex(trackIndexInGroup)
        
        return track
    }
    
    private func getAbsoluteIndexForGroupedTrack(_ groupType: GroupType, _ groupIndex: Int, _ trackIndex: Int) -> Int {
        
        if (groupIndex == 0) {
            return trackIndex
        }
        
        var absIndex = 0
        for i in 0...(groupIndex - 1) {
            absIndex += playlist.getGroupAt(groupType, i).size()
        }
        
        absIndex += trackIndex
        
        return absIndex
    }
    
    private func getAbsoluteIndexesForGroup(_ groupType: GroupType, _ groupIndex: Int, _ group: Group) -> IndexSet {
        
        if (groupIndex == 0) {
            return IndexSet(0...(group.size() - 1))
        }
        
        var absIndex = 0
        for i in 0...(groupIndex - 1) {
            absIndex += playlist.getGroupAt(groupType, i).size()
        }
        
        return IndexSet(absIndex...(absIndex + group.size() - 1))
    }
    
    private func wrapTrack(_ track: Track) -> IndexedTrack {
        
        let index = playlist.indexOfTrack(track)
        return IndexedTrack(track, index!)
    }
    
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
    
    func getPersistentState() -> PlaybackSequenceState {
        
        let state = PlaybackSequenceState()
        
        let modes = sequence.getRepeatAndShuffleModes()
        state.repeatMode = modes.repeatMode
        state.shuffleMode = modes.shuffleMode
        
        return state
    }
    
    // --------------- PlaylistChangeListener methods ----------------
    
    // TODO
    
    func tracksAdded(_ addResults: [TrackAddResult]) {
        
        if (addResults.isEmpty) {
            return
        }

        switch scope.type {
            
        case .allTracks:
            
            // Just need to update the tracks count
            sequence.updateSize(playlist.size())
            
        case .allArtists, .allAlbums, .allGenres:
            
            // TODO (find out where (absolute index) new tracks were inserted, and insert the new elements into the sequence)
            return
            
        case .artist, .album, .genre:
            
            // Check if a track was added to the playing artist/album/genre
            let playingGroup = scope.scope!
            let resultsForGroup = countAddResultsForGroup(playingGroup, addResults)
            
            if resultsForGroup > 0 {
                sequence.updateSize(sequence.size() + resultsForGroup)
            }
        }
    }
    
    // Searches the add results to find out how many tracks were added to a specific group
    private func countAddResultsForGroup(_ group: Group, _ addResults: [TrackAddResult]) -> Int {
        
        var count = 0
        
        addResults.forEach({
        
            let resultGroup = $0.groupingPlaylistResults[group.type]!.track.group
            if resultGroup === group {
                count += 1
            }
        })
        
        return count
    }
    
    func tracksRemoved(_ removeResults: RemoveOperationResults) {
        
        if (removeResults.flatPlaylistResults.isEmpty) {
            return
        }
        
        switch scope.type {
            
        case .allTracks:
            
            // Tell the sequence which rows were removed
             sequence.removeElements(removeResults.flatPlaylistResults)
            
        case .allArtists, .allAlbums, .allGenres:
            
            // TODO (find out where (absolute index) new tracks were removed, and remove those elements from the sequence)
            var indexesRemoved: [Int] = [Int]()
            
            let resultsForType = removeResults.groupingPlaylistResults[scope.type.toGroupType()!]!.results
            
            
            return
            
        case .artist, .album, .genre:
            
            // Check if a track was removed from the playing artist/album/genre, or if the entire group was removed
            let playingGroup = scope.scope!
            
            let resultsForType = removeResults.groupingPlaylistResults[playingGroup.type]!.results
            
            for result in resultsForType {
                
                if let trackRemoved = result as? TracksRemovedResult {
                    
                    if (trackRemoved.parentGroup === playingGroup) {
                        
                        sequence.removeElements(trackRemoved.trackIndexesInGroup)
                        break
                    }
                    
                } else {
                    
                    // Group
                    let groupRemoved = result as! GroupRemovedResult
                        
                    if (groupRemoved.group === playingGroup) {
                        
                        sequence.clear()
                        scope.scope = nil
                        
                        break
                    }
                }
            }
        }
    }
    
    func trackReordered(_ oldIndex: Int, _ newIndex: Int) {
        sequence.trackReordered(oldIndex, newIndex)
    }
    
    func playlistReordered(_ newCursor: Int?) {
        sequence.playlistReordered(newCursor)
    }
    
    func playlistCleared() {
        sequence.playlistCleared()
    }
    
    func playlistTypeChanged(_ playlistType: PlaylistType) {
        self.playlistType = playlistType
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if let msg = notification as? PlaylistTypeChangedNotification {
            playlistTypeChanged(msg.newPlaylistType)
            return
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        return EmptyResponse.instance
    }
}

class SequenceScope {
    
    var type: SequenceScopes
    
    // If only a particular artist/album/genre is being played back, holds the specific artist/album/genre group
    var scope: Group?
    
    init(_ type: SequenceScopes) {
        self.type = type
    }
}

enum SequenceScopes {
    
    case allTracks
    case allArtists
    case allAlbums
    case allGenres
    case artist
    case album
    case genre
    
    func toGroupType() -> GroupType? {
        
        switch self {
            
        case .allTracks: return nil
            
        case .allArtists, .artist: return .artist
            
        case .allAlbums, .album: return .album
            
        case .allGenres, .genre: return .genre
            
        }
    }
}
