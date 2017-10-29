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
        
        let tim = TimerUtils.start("trackForAbsIndex")
        
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
        
        tim.end()
        return track
    }
    
    private func wrapTrack(_ track: Track) -> IndexedTrack {
        
        let tim = TimerUtils.start("wrapTrack")
        
        let index = playlist.indexOfTrack(track)
        
        tim.end()
        
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
    
    func trackAdded(_ track: Track) {
        sequence.trackAdded(track)
    }
    
    func tracksRemoved(_ removedTrackIndexes: [Int], _ removedTracks: [Track]) {
        sequence.tracksRemoved(removedTrackIndexes, removedTracks)
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
}
