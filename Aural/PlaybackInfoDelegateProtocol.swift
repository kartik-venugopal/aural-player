import Foundation

protocol PlaybackInfoDelegateProtocol {
    
    // Returns the current playback state of the player. See PlaybackState for more details
    func getPlaybackState() -> PlaybackState
    
    // Returns the current playback position of the player, for the current track, in terms of seconds and percentage (of the duration)
    func getSeekPosition() -> (seconds: Double, percentage: Double)
    
    // Returns the currently playing track (with its index)
    func getPlayingTrack() -> IndexedTrack?
}
