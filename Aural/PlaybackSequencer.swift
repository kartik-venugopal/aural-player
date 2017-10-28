import Foundation

class PlaybackSequencer: PlaybackSequencerProtocol, PlaylistChangeListener {
    
    private var sequence: PlaybackSequence
    
    private var playlist: PlaylistAccessorProtocol
    
    init(_ playlist: PlaylistAccessorProtocol, _ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode) {
        self.sequence = PlaybackSequence(0, repeatMode, shuffleMode)
        self.playlist = playlist
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
}
