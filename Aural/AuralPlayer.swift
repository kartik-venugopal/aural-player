
import Cocoa

/*
    Contract for an audio player that is responsible for actual execution of playback control requests (play/pause/next/previous track, etc)
*/
protocol AuralPlayer {
    
    // Initializes the player with state remembered from the last app execution
    func loadPlayerState(_ state: SavedPlayerState)
    
    // Plays a track associated with a new playback session
    func play(_ playbackSession: PlaybackSession)
    
    // Pauses the currently playing track
    func pause()
    
    // Resumes playback of the currently playing track
    func resume()
    
    // Stops playback of the currently playing track, in preparation for playback of a new track. Releases all resources associated with the currently playing track.
    func stop()
    
    // Seeks to a certain time in the track for the given playback session
    func seekToTime(_ playbackSession: PlaybackSession, _ seconds: Double)
    
    // Gets the playback position (in seconds) of the currently playing track
    func getSeekPosition() -> Double
    
    // Encapsulates all current player state in an object and returns it. This is useful when persisting "remembered" player state prior to app shutdown
    func getPlayerState() -> SavedPlayerState
    
    // Does anything that needs to be done before the app exits - releasing resources
    func tearDown()
}
