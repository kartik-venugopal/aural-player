import Foundation

class PlaybackSequencer: PlaybackSequencerProtocol, PlaylistChangeListener, MessageSubscriber {
    
    private var sequence: PlaybackSequence
    private var scope: SequenceScope
    
    private var playlist: PlaylistAccessorProtocol
    
    init(_ playlist: PlaylistAccessorProtocol, _ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode) {
        
        self.sequence = PlaybackSequence(0, repeatMode, shuffleMode)
        self.playlist = playlist
        self.scope = SequenceScope(.allTracks)
        
        SyncMessenger.subscribe(.playlistTypeChangedNotification, subscriber: self)
    }
    
    // No track is currently playing
    func begin() -> IndexedTrack? {
        
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
        sequence.select(index)
        return getTrackForIndex(index)!
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
        var group = playlist.getGroupAt(groupType, 0)
        
        var tracks = 0
        var tracksInGroup = 0
        
        while (tracks < index) {
            
            while (tracksInGroup < group.size() && tracks < index) {
                tracksInGroup += 1
                tracks += 1
            }
            
            if (tracks == index) {
                let track = group.trackAtIndex(tracksInGroup)
                print("Track for absIndex:", index, "=", track.conciseDisplayName)
                return track
            }
            
            groupIndex += 1
            group = playlist.getGroupAt(groupType, groupIndex)
        }
        
        let track = group.trackAtIndex(tracksInGroup)
        print("Track for absIndex:", index, "=", track.conciseDisplayName)
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
    
    func select(_ track: Track) -> IndexedTrack {
        
        let groupType: GroupType
        let newType: SequenceScopes
        
        switch scope.type {
            
        case .allAlbums, .album:
            
            newType = .album
            groupType = .album
            
        case .allArtists, .artist:
            
            newType = .artist
            groupType = .artist
            
        case .allGenres, .genre:
            
            newType = .genre
            groupType = .genre
            
        default:
            
            newType = .artist
            groupType = .artist
            
        }
        
        scope.type = newType
        
        let groupInfo = playlist.getGroupingInfoForTrack(groupType, track)
        let group = groupInfo.group
        scope.scope = group
        
        sequence.reset(tracksCount: group.size())
        
        return select(groupInfo.trackIndex)
    }
    
    func select(_ group: Group) -> IndexedTrack {
        
        let newType: SequenceScopes
        
        switch scope.type {
            
        case .allAlbums: newType = .album
            
        case .allArtists: newType = .artist
            
        case .allGenres: newType = .genre
            
        default: newType = .artist
            
        }
        
        scope.type = newType
        scope.scope = group
        sequence.reset(tracksCount: group.size())
        sequence.resetCursor()
        
        return subsequent()!
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
    
    func scopeTypeChanged(_ playlistType: PlaylistType) {
        
        if (sequence.getCursor() != nil) {
            print("Ignoring playlist type change, because track is playing")
            return
        }
        
        var type: SequenceScopes
        
        switch playlistType {
            
        case .albums: type = .allAlbums
            
        case .artists: type = .allArtists
            
        case .genres: type = .allGenres
            
        case .tracks: type = .allTracks
            
        }

        scope.type = type
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if let msg = notification as? PlaylistTypeChangedNotification {
            scopeTypeChanged(msg.newPlaylistType)
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
