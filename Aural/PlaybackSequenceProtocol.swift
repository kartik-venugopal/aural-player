import Foundation

/*
    Contract for read/write operations on the playback sequence. The playback sequence determines the order in which tracks will be selected for playback.
 
    This will depend on:
 
    - the order of tracks in the playlist from which the sequence was created (i.e. the playback scope)
    - the repeat and shuffle modes
 */
protocol PlaybackSequenceProtocol {
    
    /*
        NOTE - "Subsequent track" is the track in the sequence that will be selected automatically by the app if playback of a track completes. It involves no user input.
    
        By contrast, "Next track" is the track in the sequence that will be selected if the user requests the next track in the sequence. This may or may not be the same as the "Subsequent track"
     */
    
    // NOTE - A non-nil value represents the index, within the sequence, of the track selected for playback. A nil return value means no applicable track.
   
    // Peeks at (without selecting for playback) the subsequent track in the sequence
    func peekSubsequent() -> Int?
    
    // Selects, for playback, the subsequent track in the sequence
    func subsequent() -> Int?
    
    // Peeks at (without selecting for playback) the previous track in the sequence
    func peekPrevious() -> Int?
    
    // Selects, for playback, the previous track in the sequence
    func previous() -> Int?
    
    // Peeks at (without selecting for playback) the next track in the sequence
    func peekNext() -> Int?
    
    // Selects, for playback, the next track in the sequence
    func next() -> Int?
    
    // Selects, for playback, the track with the given index
    func select(_ index: Int)
    
    // Returns the index of the currently playing track
    var cursor: Int? {get}
    
    // Toggles between repeat modes. See RepeatMode for more details. Returns the new repeat and shuffle mode after performing the toggle operation.
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    // Toggles between shuffle modes. See ShuffleMode for more details. Returns the new repeat and shuffle mode after performing the toggle operation.
    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    // Sets the repeat mode to a specific value. Returns the new repeat and shuffle mode after performing the toggle operation.
    func setRepeatMode(_ repeatMode: RepeatMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    // Sets the shuffle mode to a specific value. Returns the new repeat and shuffle mode after performing the toggle operation.
    func setShuffleMode(_ shuffleMode: ShuffleMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    // Returns the current repeat and shuffle modes
    var repeatAndShuffleModes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {get}
 
    // Returns the size of the sequence (i.e. number of tracks)
    var size: Int {get}
    
    // Clears the sequence of all elements
    func clear()
}
