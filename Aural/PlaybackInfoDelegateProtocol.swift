import Foundation

/*
    Contract for a middleman/delegate that retrieves information about current playback state
 */
protocol PlaybackInfoDelegateProtocol {
    
    // Returns the current playback state of the player. See PlaybackState for more details
    func getPlaybackState() -> PlaybackState
    
    // Returns the current seek position of the player, for the current track, in terms of seconds and percentage (of the duration)
    func getSeekPosition() -> (seconds: Double, percentage: Double)
    
    // Returns the currently playing track (with its index), if a track is currently playing
    func getPlayingTrack() -> IndexedTrack?
}
