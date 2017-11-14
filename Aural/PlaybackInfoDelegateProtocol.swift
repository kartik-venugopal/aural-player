import Foundation

/*
    Contract for a middleman/delegate that retrieves information about current playback state
 */
protocol PlaybackInfoDelegateProtocol {
    
    // Returns the current playback state of the player. See PlaybackState for more details
    func getPlaybackState() -> PlaybackState
    
    /*
        Returns summary information about the current playback sequence
     
        scope - the scope of the sequence which could either be an entire playlist (for ex, all tracks), or a single group (for ex, Artist "Madonna" or Genre "Pop")
     
        trackIndex - the relative index of the currently playing track within the sequence (as opposed to within the entire playlist)
     
        totalTracks - the total number of tracks in the current sequence
     */
    func getPlaybackSequenceInfo() -> (scope: SequenceScope, trackIndex: Int, totalTracks: Int)
    
    // Returns the current seek position of the player, for the current track, i.e. time elapsed, in terms of seconds and percentage (of the total duration), and the total track duration (also in seconds)
    func getSeekPosition() -> (timeElapsed: Double, percentageElapsed: Double, trackDuration: Double)
    
    // Returns the currently playing track (with its index), if a track is currently playing
    func getPlayingTrack() -> IndexedTrack?
    
    // Returns grouping info for the playing track, for a specific group type
    func getPlayingTrackGroupInfo(_ groupType: GroupType) -> GroupedTrack?
    
    // Returns the current repeat and shuffle modes
    func getRepeatAndShuffleModes() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
}
