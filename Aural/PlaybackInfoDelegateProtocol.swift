import Foundation

/*
    Contract for a middleman/delegate that retrieves information about current playback state
 */
protocol PlaybackInfoDelegateProtocol {
    
    // Returns the current playback state of the player. See PlaybackState for more details
    func getPlaybackState() -> PlaybackState
    
    func getPlaybackSequenceInfo() -> (scope: SequenceScope, trackIndex: Int, totalTracks: Int)
    
    // Returns the current seek position of the player, for the current track, i.e. time elapsed, in terms of seconds and percentage (of the total duration), and the total track duration (also in seconds)
    func getSeekPosition() -> (timeElapsed: Double, percentageElapsed: Double, trackDuration: Double)
    
    // Returns the currently playing track (with its index), if a track is currently playing
    func getPlayingTrack() -> IndexedTrack?
    
    // Returns grouping info for the playing track, within a specific playlist type
    func getPlayingTrackGroupInfo(_ groupType: GroupType) -> GroupedTrack?
}
