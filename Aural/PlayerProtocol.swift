import Cocoa

/*
    Contract for an audio player that performs track playback
 */
protocol PlayerProtocol {
    
    // Plays a given track
    func play(_ track: Track)
    
    // Pauses the currently playing track
    func pause()
    
    // Resumes playback of the currently playing track
    func resume()
    
    // Stops playback of the currently playing track
    func stop()
    
    // Seeks to a certain time within the currently playing track
    func seekToTime(_ track: Track, _ seconds: Double)
    
    // Gets the playback position (in seconds) of the currently playing track
    func getSeekPosition() -> Double
    
    // Returns the current playback state of the player. See PlaybackState for more details
    func getPlaybackState() -> PlaybackState
    
    /*
        Returns a TimeInterval indicating when the currently playing track began playing. Returns nil if no track is playing.
     
        The TimeInterval is relative to the last system start time, i.e. it is the systemUpTime. See ProcessInfo.processInfo.systemUpTime
     */
    func getPlayingTrackStartTime() -> TimeInterval?
    
    // MARK: Loop functions
    
    /*
        Toggles the state of an A->B playback loop for the currently playing track. There are 3 possible states:
     
        1 - loop started: the start of the loop has been marked
        2 - loop ended: the end (and start) of the loop has been marked, completing the definition of the playback loop. Any subsequent playback will now proceed within the scope of the loop, i.e. between the 2 loop points: start and end
        3 - loop removed: any previous loop definition has been removed/cleared. Playback will proceed normally from start -> end of the playing track
     
        Returns the definition of the current loop, if one is currently defined.
     */
    func toggleLoop() -> PlaybackLoop?
    
    func removeLoop()
    
    func getPlaybackLoop() -> PlaybackLoop?
}
