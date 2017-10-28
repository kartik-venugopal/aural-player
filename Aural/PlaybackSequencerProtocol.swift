import Foundation

/*
 Contract for read/write operations on the playback sequence. The playback sequence determines the order in which playlist tracks will be selected for playback.
 
 This will depend on:
 
 - the type of playlist initiating the sequence (tracks or artists, etc) 
 - the order of tracks in the playlist
 - the repeat and shuffle modes
 */
protocol PlaybackSequencerProtocol {
    
    /*  NOTE - "Subsequent track" is the track in the sequence that will be selected automatically by the app if playback of a track completes. It involves no user input.
     
     By contrast, "Next track" is the track in the sequence that will be selected if the user requests the next track in the sequence. This may or may not be the same as the "Subsequent track"
     */
    
    // NOTE - Nil return values mean no applicable track
    
    // Peeks at (without selecting for playback) the subsequent track in the sequence
    func peekSubsequent() -> IndexedTrack?
    
    // Selects, for playback, the first track in the sequence
    func begin() -> IndexedTrack?
    
    // Selects, for playback, the subsequent track in the sequence
    func subsequent() -> IndexedTrack?
    
    // Peeks at (without selecting for playback) the previous track in the sequence
    func peekPrevious() -> IndexedTrack?
    
    // Selects, for playback, the previous track in the sequence
    func previous() -> IndexedTrack?
    
    // Peeks at (without selecting for playback) the next track in the sequence
    func peekNext() -> IndexedTrack?
    
    // Selects, for playback, the next track in the sequence
    func next() -> IndexedTrack?
    
    // Selects, for playback, the track with the given index
    func select(_ index: Int) -> IndexedTrack
    
    // Selects, for playback, the track with the given index
    func select(_ track: Track) -> IndexedTrack
    
    // Selects, for playback, the track with the given index
    func select(_ group: Group) -> IndexedTrack
    
    // Returns the index of the currently playing track
    func getPlayingTrack() -> IndexedTrack?
    
    // Toggles between repeat modes. See RepeatMode for more details. Returns the new repeat and shuffle mode after performing the toggle operation.
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    // Toggles between shuffle modes. See ShuffleMode for more details. Returns the new repeat and shuffle mode after performing the toggle operation.
    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    // Sets the repeat mode to a specific value. Returns the new repeat and shuffle mode after performing the toggle operation.
    func setRepeatMode(_ repeatMode: RepeatMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    // Sets the shuffle mode to a specific value. Returns the new repeat and shuffle mode after performing the toggle operation.
    func setShuffleMode(_ shuffleMode: ShuffleMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
}
