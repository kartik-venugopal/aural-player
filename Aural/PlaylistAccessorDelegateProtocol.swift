import Foundation

/*
    Contract for a middleman/delegate that relays read-only operations to the playlist
 */
protocol PlaylistAccessorDelegateProtocol {
    
    // Retrieves all tracks
    func allTracks() -> [Track]
    
    // Returns the track at a given index. Returns nil if an invalid index is specified.
    func trackAtIndex(_ index: Int?) -> IndexedTrack?
    
    /*
        Determines the index of a given track, within the flat playlist. Returns nil if the track doesn't exist within the playlist.
     
        NOTE - This function is only intended to be used by the flat playlist. The result is meaningless to a grouping/hierarchical playlist.
     */
    func indexOfTrack(_ track: Track) -> IndexedTrack?
    
    // Returns the size (i.e. total number of tracks) of the playlist
    func size() -> Int
    
    // Returns the total duration of the playlist tracks
    func totalDuration() -> Double
    
    // Returns a summary for a specific playlist type - size (number of tracks), total duration, and number of groups. Number of groups will always be 0 for the flat (tracks) playlist.
    func summary(_ playlistType: PlaylistType) -> (size: Int, totalDuration: Double, numGroups: Int)
    
    // Searches the playlist, given certain query parameters, and returns all matching results. The playlistType argument indicates which playlist type the results are to be displayed within. The search results will contain track location information tailored to the specified playlist type.
    func search(_ searchQuery: SearchQuery, _ playlistType: PlaylistType) -> SearchResults
    
    // Returns the group, of a specific type, at the given index.
    func groupAtIndex(_ type: GroupType, _ index: Int) -> Group
    
    // Returns the total number of groups of a specific type, within the playlist.
    func numberOfGroups(_ type: GroupType) -> Int
    
    // Given a track and a specific group type, returns all grouping information, such as the parent group and the index of the track within that group.
    func groupingInfoForTrack(_ type: GroupType, _ track: Track) -> GroupedTrack
    
    // Returns the index of a group within the appropriate grouping/hierarchical playlist (indicated by the group's type).
    func indexOfGroup(_ group: Group) -> Int
    
    // Returns the display name for a track within a specific playlist. For example, within the Artists playlist, the display name of a track will consist of just its title.
    func displayNameForTrack(_ playlistType: PlaylistType, _ track: Track) -> String
    
    func getGapBeforeTrack(_ track: Track) -> PlaybackGap?
    
    func getGapAfterTrack(_ track: Track) -> PlaybackGap?
}
