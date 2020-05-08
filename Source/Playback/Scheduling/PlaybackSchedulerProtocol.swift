import Foundation

protocol PlaybackSchedulerProtocol {
    
    func playTrack(_ playbackSession: PlaybackSession, _ startPosition: Double)
    
    func playLoop(_ playbackSession: PlaybackSession, _ beginPlayback: Bool)
    
    func playLoop(_ playbackSession: PlaybackSession, _ playbackStartTime: Double, _ beginPlayback: Bool)
    
    // The A->B loop has been removed. Need to resume normal playback till the end of the track.
    func endLoop(_ playbackSession: PlaybackSession, _ loopEndTime: Double)
    
    // Seeks to a certain position (seconds) in the specified track. Returns the calculated start frame.
    func seekToTime(_ playbackSession: PlaybackSession, _ seconds: Double, _ beginPlayback: Bool)
    
    func pause()
    
    func resume()

    // Stops the scheduling of audio buffers, in response to a request to stop playback (or when seeking to a new position). Marks the end of a "playback session".
    func stop()
    
    // Retrieves the current seek position, in seconds
    var seekPosition: Double {get}
}
