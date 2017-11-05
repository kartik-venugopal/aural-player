import Foundation

class PlaybackSequencer: PlaybackSequencerProtocol, PlaylistChangeListenerProtocol, MessageSubscriber {
    
    private var sequence: PlaybackSequence
    private var scope: SequenceScope = SequenceScope(.allTracks)
    private var playlistType: PlaylistType = .tracks
    
    private var playlist: PlaylistAccessorProtocol
    
    private var playingTrack: Track?
    
    init(_ playlist: PlaylistAccessorProtocol, _ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode) {
        
        self.sequence = PlaybackSequence(0, repeatMode, shuffleMode)
        self.playlist = playlist
        
        SyncMessenger.subscribe(messageTypes: [.playlistTypeChangedNotification], subscriber: self)
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
    
    func end() {
        
        sequence.resetCursor()
        playingTrack = nil
        
        scope.scope = nil
        scope.type = playlistTypeToGeneralScopeType(self.playlistType)
    }
    
    private func playlistTypeToGeneralScopeType(_ playlistType: PlaylistType) -> SequenceScopes {
        
        switch playlistType {
            
        case .artists: return .allArtists
            
        case .albums: return .allAlbums
            
        case .genres: return .allGenres
            
        case .tracks: return .allTracks
            
        }
    }
    
    func peekSubsequent() -> IndexedTrack? {
        return getTrackForIndex(sequence.peekSubsequent())
    }
    
    func subsequent() -> IndexedTrack? {
        let subsequent = getTrackForIndex(sequence.subsequent())
        playingTrack = subsequent?.track
        return subsequent
    }
    
    func peekNext() -> IndexedTrack? {
        return getTrackForIndex(sequence.peekNext())
    }
    
    func next() -> IndexedTrack? {
        let next = getTrackForIndex(sequence.next())
        
        if (next != nil) {
            playingTrack = next?.track
        }
        return next
    }
    
    func peekPrevious() -> IndexedTrack? {
        return getTrackForIndex(sequence.peekPrevious())
    }
    
    func previous() -> IndexedTrack? {
        
        let previous = getTrackForIndex(sequence.previous())
        
        if (previous != nil) {
            playingTrack = previous?.track
        }
        return previous
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
        let track = getTrackForIndex(index)!
        playingTrack = track.track
        return track
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
        
        let groupInfo = playlist.groupingInfoForTrack(groupType, track)
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
        return playingTrack != nil ? wrapTrack(playingTrack!) : nil
    }
    
    private func getTrackForIndex(_ optionalIndex: Int?) -> IndexedTrack? {
        
        // Unwrap optional cursor value
        if let index = optionalIndex {
            
            switch scope.type {
                
            case .album: return wrapTrack(scope.scope!.trackAtIndex(index))
                
            case .artist: return wrapTrack(scope.scope!.trackAtIndex(index))
                
            case .genre: return wrapTrack(scope.scope!.trackAtIndex(index))
                
            case .allTracks: return playlist.trackAtIndex(index)
                
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
            tracks += playlist.groupAtIndex(groupType, groupIndex).size()
            groupIndex += 1
        }
        
        // If you've overshot the target index, go back one group, and use the offset to calculate track index within that previous group
        if (tracks > index) {
            groupIndex -= 1
            trackIndexInGroup = playlist.groupAtIndex(groupType, groupIndex).size() - (tracks - index)
        }
        
        let group = playlist.groupAtIndex(groupType, groupIndex)
        let track = group.trackAtIndex(trackIndexInGroup)
        
        return track
    }
   
    private func getAbsoluteIndexForGroupedTrack(_ groupType: GroupType, _ groupIndex: Int, _ trackIndex: Int) -> Int {
        
        if (groupIndex == 0) {
            return trackIndex
        }
        
        var absIndex = 0
        for i in 0...(groupIndex - 1) {
            absIndex += playlist.groupAtIndex(groupType, i).size()
        }
        
        return absIndex + trackIndex
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
    
    // --------------- PlaylistChangeListenerProtocol methods ----------------
    
    func tracksAdded(_ addResults: [TrackAddResult]) {
        
        if (!addResults.isEmpty) {
            updateSequence()
        }
    }
    
    func tracksRemoved(_ removeResults: TrackRemovalResults, _ playingTrackRemoved: Bool) {
        
        if (playingTrackRemoved) {
            end()
        }
        
        if (!removeResults.flatPlaylistResults.isEmpty) {
            updateSequence()
        }
    }
    
    func tracksReordered(_ playlistType: PlaylistType) {
        
        if (scope.type.toPlaylistType() == playlistType) {
            updateSequence()
        }
    }
    
    func playlistReordered(_ playlistType: PlaylistType) {
        
        if (scope.type.toPlaylistType() == playlistType) {
            updateSequence()
        }
    }
    
    func playlistCleared() {
        sequence.clear()
        end()
    }
    
    private func calculateNewCursor() -> Int? {
        
        if let playingTrack = playingTrack {
            
            switch scope.type {
                
            case .allArtists, .allAlbums, .allGenres:
                
                let groupInfo = playlist.groupingInfoForTrack(scope.type.toGroupType()!, playingTrack)
                
                return getAbsoluteIndexForGroupedTrack(scope.type.toGroupType()!, groupInfo.groupIndex, groupInfo.trackIndex)
                
            case .artist, .album, .genre:
                
                return scope.scope!.indexOfTrack(playingTrack)
                
            case .allTracks:
                
                return playlist.indexOfTrack(playingTrack)
            }
        }
        
        return nil
    }
    
    private func updateSequence() {
        
        var sequenceSize: Int
        
        switch scope.type {
            
        case .allTracks, .allArtists, .allAlbums, .allGenres: sequenceSize = playlist.size()
            
        case .artist, .album, .genre: sequenceSize = scope.scope!.size()
            
        }
        
        if (sequence.getCursor() != nil) {
            
            // Update the cursor
            let newCursor = calculateNewCursor()
            sequence.reset(tracksCount: sequenceSize, firstTrackIndex: newCursor)
            
        } else {
            sequence.reset(tracksCount: sequenceSize)
        }
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
    
    func toPlaylistType() -> PlaylistType {
        
        switch self {
            
        case .allTracks: return .tracks
            
        case .allArtists, .artist: return .artists
            
        case .allAlbums, .album: return .albums
            
        case .allGenres, .genre: return .genres
            
        }
    }
}
