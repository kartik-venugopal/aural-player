import Foundation

/*
    Contract for a middleman/delegate that retrieves information about current playback state
 */
protocol PlaybackInfoDelegateProtocol {
    
    // Returns the current playback state of the player. See PlaybackState for more details
    var state: PlaybackState {get}
    
    // Returns the current seek position of the player, for the current track, i.e. time elapsed, in terms of seconds and percentage (of the total duration), and the total track duration (also in seconds)
    var seekPosition: (timeElapsed: Double, percentageElapsed: Double, trackDuration: Double) {get}
    
    // Returns the current track, if there is one
    var currentTrack: Track? {get}
    
    // Returns the currently playing (or paused) track, if there is one
    var playingTrack: Track? {get}
    
    // Returns the currently transcoding (and pending playback) track, if there is one
    var transcodingTrack: Track? {get}
    
    // For the currently playing track, returns the total number of defined chapter markings
    var chapterCount: Int {get}
    
    // For the currently playing track, returns the index of the currently playing chapter. Returns nil if:
    // 1 - There are no chapter markings for the current track
    // 2 - There are chapter markings but the current seek position is not within the time bounds of any of the chapters
    var playingChapter: IndexedChapter? {get}
    
    /*
        Returns a TimeInterval indicating when the currently playing track began playing. Returns nil if no track is playing.
     
        The TimeInterval is relative to the last system start time, i.e. it is the systemUpTime. See ProcessInfo.processInfo.systemUpTime
    */
    var playingTrackStartTime: TimeInterval? {get}
    
    // Retrieves information about the playback loop defined on a segment of the currently playing track, if there is a playing track and a loop for it
    var playbackLoop: PlaybackLoop? {get}
}
