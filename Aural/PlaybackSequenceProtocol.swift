import Foundation

protocol PlaybackSequenceProtocol {
    
    func peekSubsequent() -> Int?
    
    func subsequent() -> Int?
    
    func peekPrevious() -> Int?
    
    func previous() -> Int?
    
    func peekNext() -> Int?
    
    func next() -> Int?
    
    func select(_ index: Int)
    
    // Returns the index of the currently playing track
    func getCursor() -> Int?
    
    // Toggles between repeat modes. See RepeatMode for more details. Returns the new repeat and shuffle mode after performing the toggle operation.
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    // Toggles between shuffle modes. See ShuffleMode for more details. Returns the new repeat and shuffle mode after performing the toggle operation.
    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    func setRepeatMode(_ repeatMode: RepeatMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    func setShuffleMode(_ shuffleMode: ShuffleMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    func getRepeatMode() -> RepeatMode
    
    func getShuffleMode() -> ShuffleMode
}
