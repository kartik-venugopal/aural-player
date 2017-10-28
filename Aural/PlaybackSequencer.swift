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
    
    func begin() -> IndexedTrack? {
        return subsequent()
    }
    
    func peekSubsequent() -> IndexedTrack? {
        return playlist.peekTrackAt(sequence.peekSubsequent())
    }
    
    func subsequent() -> IndexedTrack? {
        return playlist.peekTrackAt(sequence.subsequent())
    }
    
    func peekNext() -> IndexedTrack? {
        return playlist.peekTrackAt(sequence.peekNext())
    }
    
    func next() -> IndexedTrack? {
        return playlist.peekTrackAt(sequence.next())
    }
    
    func peekPrevious() -> IndexedTrack? {
        return playlist.peekTrackAt(sequence.peekPrevious())
    }
    
    func previous() -> IndexedTrack? {
        return playlist.peekTrackAt(sequence.previous())
    }
    
    func select(_ index: Int) -> IndexedTrack {
        sequence.select(index)
        return playlist.peekTrackAt(index)!
    }
    
    func getPlayingTrack() -> IndexedTrack? {
        return playlist.peekTrackAt(sequence.getCursor())
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
    
    func select(_ track: Track) {
        // TODO: Figure out the index of this track within the scope
        // Reset the sequence with a tracks count and this track's index as the first index (cursor)
    }
    
    func select(_ group: Group) {
        
        // Reset the sequence with a tracks count (group.size()) and the first track under this group as the first index (cursor = 0)
        
        let newType: SequenceScopes
        
        switch scope.type {
            
        case .allAlbums: newType = .album
            
        case .allArtists: newType = .artist
            
        case .allGenres: newType = .genre
            
        default: newType = .artist
            
        }
        
        scope.type = newType
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
        
        var type: SequenceScopes
        
        switch playlistType {
            
        case .albums: type = .allAlbums
            
        case .artists: type = .allArtists
            
        case .genres: type = .allGenres
            
        case .tracks: type = .allTracks
            
        }
        
        print("Setting scope.plType to:", String(describing: type))
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
