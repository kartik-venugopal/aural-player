import Foundation

protocol PlaybackSequenceAccessor {
    
    func peekSubsequentTrack() -> IndexedTrack?
    
    func subsequentTrack() -> IndexedTrack?
    
    func peekPreviousTrack() -> IndexedTrack?
    
    func previousTrack() -> IndexedTrack?
    
    func peekNextTrack() -> IndexedTrack?
    
    func nextTrack() -> IndexedTrack?
    
    func peekTrackAt(_ index: Int?) -> IndexedTrack?
    
    func selectTrackAt(_ index: Int?) -> IndexedTrack?
    
    // Returns the currently playing track (with its index)
    func getPlayingTrack() -> IndexedTrack?
    
    func getRepeatMode() -> RepeatMode
    
    func getShuffleMode() -> ShuffleMode
}
