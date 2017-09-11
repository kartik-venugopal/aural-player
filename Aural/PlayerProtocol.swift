import Cocoa

/*
 Contract for an audio player that is responsible for actual execution of playback control requests (play/pause/next/previous track, etc)
 */
protocol PlayerProtocol {
    
    // Plays a track associated with a new playback session
    func play(_ track: Track)
    
    // Pauses the currently playing track
    func pause()
    
    // Resumes playback of the currently playing track
    func resume()
    
    // Stops playback of the currently playing track, in preparation for playback of a new track. Releases all resources associated with the currently playing track.
    func stop()
    
    // Seeks to a certain time in the track for the given playback session
    func seekToTime(_ track: Track, _ seconds: Double)
    
    // Gets the playback position (in seconds) of the currently playing track
    func getSeekPosition() -> Double
    
    // Returns the current playback state of the player. See PlaybackState for more details
    func getPlaybackState() -> PlaybackState
}
