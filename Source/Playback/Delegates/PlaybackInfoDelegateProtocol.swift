import Foundation

/*
    Contract for a middleman/delegate that retrieves information about current playback state
 */
protocol PlaybackInfoDelegateProtocol {
    
    // Returns the current playback state of the player. See PlaybackState for more details
    var state: PlaybackState {get}
    
    /*
        Returns summary information about the current playback sequence
     
        scope - the scope of the sequence which could either be an entire playlist (for ex, all tracks), or a single group (for ex, Artist "Madonna" or Genre "Pop")
     
        trackIndex - the relative index of the currently playing track within the sequence (as opposed to within the entire playlist)
     
        totalTracks - the total number of tracks in the current sequence
     */
    var sequenceInfo: (scope: SequenceScope, trackIndex: Int, totalTracks: Int) {get}
    
    // Returns the current seek position of the player, for the current track, i.e. time elapsed, in terms of seconds and percentage (of the total duration), and the total track duration (also in seconds)
    var seekPosition: (timeElapsed: Double, percentageElapsed: Double, trackDuration: Double) {get}
    
    // Returns the currently playing track (with its index), if a track is currently playing
    var playingTrack: IndexedTrack? {get}
    
    // Currently waiting track
    var waitingTrack: IndexedTrack? {get}
    
    // For the currently playing track, returns the total number of defined chapter markings
    var chapterCount: Int {get}
    
    // For the currently playing track, returns the index of the currently playing chapter. Returns nil if:
    // 1 - There are no chapter markings for the current track
    // 2 - There are chapter markings but the current seek position is not within the time bounds of any of the chapters
    var playingChapter: IndexedChapter? {get}
    
    // Returns the current repeat and shuffle modes
    var repeatAndShuffleModes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {get}
    
    /*
        Returns a TimeInterval indicating when the currently playing track began playing. Returns nil if no track is playing.
     
        The TimeInterval is relative to the last system start time, i.e. it is the systemUpTime. See ProcessInfo.processInfo.systemUpTime
    */
    var playingTrackStartTime: TimeInterval? {get}
    
    // Retrieves information about the playback loop defined on a segment of the currently playing track, if there is a playing track and a loop for it
    var playbackLoop: PlaybackLoop? {get}
    
    // Returns grouping info for the playing track, for a specific group type
    func playingTrackGroupInfo(_ groupType: GroupType) -> GroupedTrack?
}
