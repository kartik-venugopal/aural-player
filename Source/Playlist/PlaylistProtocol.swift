//
//  PlaylistProtocol.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A functional contract for all read-only and mutating/write playlist operations.
///
protocol PlaylistProtocol: PlaylistAccessorProtocol, PlaylistMutatorProtocol {
}

///
/// A functional contract for read-only access to the playlist.
///
protocol PlaylistAccessorProtocol {
    
//    var name: String {get set}
    
    // Retrieves all tracks, in the same order as in the flat playlist
    var tracks: [Track] {get}
    
    // Returns the size (i.e. total number of tracks) of the playlist
    var size: Int {get}
    
    // Returns the total duration of the playlist tracks
    var duration: Double {get}
    
//    // Whether or not the tracks in the playlist have been loaded into the playlist (from persistent state).
//    var needsLoadingFromPersistentState: Bool {get}
    
    /*
        Determines the index of a given track, within the flat playlist. Returns nil if the track doesn't exist within the playlist.
     
        NOTE - This function is only intended to be used by the flat playlist. The result is meaningless to a grouping/hierarchical playlist.
    */
    func indexOfTrack(_ track: Track) -> Int?
    
    func hasTrack(_ track: Track) -> Bool
    
    func hasTrackForFile(_ file: URL) -> Bool
    
    // Tries to finds a track by its filesystem file. Returns nil if not found.
    func findTrackByFile(_ file: URL) -> Track?
    
    /*
        Returns the track at a given index within the flat playlist. Returns nil if an invalid index is specified.
     
        NOTE - This function is only intended to be used by the flat playlist. The result is meaningless to a grouping/hierarchical playlist.
     */
    func trackAtIndex(_ index: Int) -> Track?
    
    // Returns a summary for a specific playlist type - size (number of tracks), total duration, and number of groups. Number of groups will always be 0 for the flat (tracks) playlist.
    func summary(_ playlistType: PlaylistType) -> (size: Int, totalDuration: Double, numGroups: Int)
    
    // Searches the playlist, given certain query parameters, and returns all matching results. The playlistType argument indicates which playlist type the results are to be displayed within. The search results will contain track location information tailored to the specified playlist type.
    func search(_ searchQuery: SearchQuery, _ playlistType: PlaylistType) -> SearchResults
    
    // Returns the group, of a specific type, at the given index, within the corresponding grouping/hierarchical playlist.
    func groupAtIndex(_ type: GroupType, _ index: Int) -> Group?
    
    // Returns the total number of groups of a specific type, within the corresponding grouping/hierarchical playlist.
    func numberOfGroups(_ type: GroupType) -> Int

    // Returns all groups of the given type
    func allGroups(_ type: GroupType) -> [Group]
    
    // Given a track and a specific group type, returns all grouping information, such as the parent group and the index of the track within that group.
    func groupingInfoForTrack(_ type: GroupType, _ track: Track) -> GroupedTrack?
    
    // Given a track and a specific group type, returns all grouping information, such as the parent group and the index of the track within that group.
    func allGroupingInfoForTrack(_ track: Track) -> [GroupType: GroupedTrack]
    
    // Returns the index of a group within the appropriate grouping/hierarchical playlist (indicated by the group's type).
    func indexOfGroup(_ group: Group) -> Int?
    
    // Returns the display name for a track within a specific playlist. For example, within the Artists playlist, the display name of a track will consist of just its title.
    func displayNameForTrack(_ playlistType: PlaylistType, _ track: Track) -> String
}

///
/// A functional contract for mutating (write) operations performed on the playlist.
///
protocol PlaylistMutatorProtocol: CommonPlaylistMutatorProtocol {
    
    /*
        Adds a single track to the playlist, and returns information about its location within the playlist. Returns nil if track is not added.
     
        NOTE:
     
            - Duplicates are not allowed (if the track already exists in the playlist, it will not be added).
     
            - All playlist types will be affected by this operation. i.e. the track will be added to all playlist types.
     */
    func addTrack(_ track: Track) -> TrackAddResult?
    
    /*
        Removes track(s) with the given indexes (i.e indexes within the flat playlist). 
     
        Returns information about the removal of the tracks from the different playlist types, to aid the view layer in determining the locations of the removed tracks and refreshing the playlist views.
     
        NOTE - All playlist types will be affected by this operation. i.e. the tracks will be removed from all playlist types.
     */
    func removeTracks(_ indexes: IndexSet) -> TrackRemovalResults
    
    /*
        Given a set of tracks and groups, removes them from the playlist. Removal of all tracks within a group will result in the removal of the group. Removal of a group will resuly in the removal of all its child tracks. The groupType argument indicates the type of the groups in the groups argument.
     
        Returns information about the removal of the tracks from the different playlist types, to aid the view layer in determining the locations of the removed tracks and refreshing the playlist views.
     
        NOTE - All playlist types will be affected by this operation. i.e. the removed tracks will be removed from all playlist types.
     */
    func removeTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> TrackRemovalResults
    
    /*
        Moves the tracks at the specified indexes, up one index, in the flat playlist, if they can be moved (they are not already at the top). Returns mappings of source indexes to destination indexes, for all the tracks (for tracks that didn't move, the new index will match the old index)
     
        Returns mappings of source locations to destination locations.
     
        NOTE:
     
            - Even if some tracks cannot move, those that can will be moved. i.e. This is not an all or nothing operation.
     
            - Only the flat playlist will be altered. The other playlist types will be unaffected by this operation. Each playlist type's sequence of tracks/groups is independent from that of all other playlist types.
     */
    func moveTracksUp(_ indexes: IndexSet) -> ItemMoveResults
    
    func moveTracksToTop(_ indexes: IndexSet) -> ItemMoveResults
    
    /*
        Moves the tracks at the specified indexes, down one index, in the flat playlist, if they can be moved (they are not already at the bottom). Returns mappings of source indexes to destination indexes, for all the tracks (for tracks that didn't move, the new index will match the old index)
     
        Returns mappings of source locations to destination locations.
     
        NOTE:
     
            - Even if some tracks cannot move, those that can will be moved. i.e. This is not an all or nothing operation.
     
            - Only the flat playlist will be altered. The other playlist types will be unaffected by this operation. Each playlist type's sequence of tracks/groups is independent from that of all other playlist types.
     */
    func moveTracksDown(_ indexes: IndexSet) -> ItemMoveResults
    
    func moveTracksToBottom(_ indexes: IndexSet) -> ItemMoveResults
    
    /*
        Moves either the specified tracks, or the specified groups (groups take precedence), up one index in the specified grouping/hierarchical playlist type, if they can be moved (they are not already at the top).
     
        Returns mappings of source indexes to destination indexes, for all the tracks/groups (for tracks/groups that didn't move, the new index will match the old index).
     
        NOTE:
     
            - If both tracks and groups are specified, only the groups will be moved.
     
            - Even if some tracks/groups cannot move, those that can will be moved. i.e. This is not an all or nothing operation.
     
            - Only the specified type of grouping/hierarchical playlist will be altered. The other playlist types will be unaffected by this operation. Each playlist type's sequence of tracks/groups is independent from that of all other playlist types.
     */
    func moveTracksAndGroupsUp(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults
    
    func moveTracksAndGroupsToTop(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults
    
    /*
        Moves either the specified tracks, or the specified groups (groups take precedence), down one index in the specified grouping/hierarchical playlist type, if they can be moved (they are not already at the bottom).
     
        Returns mappings of source indexes to destination indexes, for all the tracks/groups (for tracks/groups that didn't move, the new index will match the old index).
     
        NOTE:
     
            - If both tracks and groups are specified, only the groups will be moved.
     
            - Even if some tracks/groups cannot move, those that can will be moved. i.e. This is not an all or nothing operation.
     
            - Only the specified type of grouping/hierarchical playlist will be altered. The other playlist types will be unaffected by this operation. Each playlist type's sequence of tracks/groups is independent from that of all other playlist types.
     */
    func moveTracksAndGroupsDown(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults
    
    func moveTracksAndGroupsToBottom(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults
    
    /*
        Sorts a specific playlist type according to the specified sort parameters.
     
        NOTE: Only the specified type of playlist will be altered. The other playlist types will be unaffected by this operation. Each playlist type's sequence of tracks/groups is independent from that of all other playlist types.
     */
    func sort(_ sort: Sort, _ playlistType: PlaylistType) -> SortResults
    
    /*
        Performs a drag and drop reordering operation on the flat playlist, from a set of source indexes to a destination drop index (above the drop index). Returns the set of new destination indexes for the reordered items.
     
        NOTE: Only the flat playlist will be altered. The other playlist types will be unaffected by this operation. Each playlist type's sequence of tracks/groups is independent from that of all other playlist types.
     */
    func dropTracks(_ sourceIndexes: IndexSet, _ dropIndex: Int) -> ItemMoveResults
    
    /*
        Performs a drag and drop reordering operation on a specific grouping/hierarchical playlist. Source items (tracks or groups) are dropped, under a given parent (either the root, if groups are being moved, or a specific group, if tracks are being moved), at a destination drop index.
     
        Returns mappings of source locations to destination locations.
     
        NOTE:
     
        - If both tracks and groups are specified, only the groups will be moved.
     
        - Only the specified type of grouping/hierarchical playlist will be altered. The other playlist types will be unaffected by this operation. Each playlist type's sequence of tracks/groups is independent from that of all other playlist types.
     */
    func dropTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType, _ dropParent: Group?, _ dropIndex: Int) -> ItemMoveResults
    
    ///
    /// Re-order the playlist (tracks and groups), upon app startup, according to the sort order of the playlist from the last app launch.
    ///
    /// - Parameter state:  Application state persisted from the last app launch, including playlist sort order.
    ///                     This will determine how the playlist is reordered.
    ///
    func reOrder(accordingTo state: PlaylistPersistentState)
}

///
/// A functional contract for common mutating/write playlist operations (common to all playlist types).
///
protocol CommonPlaylistMutatorProtocol {
    
    /*
        Clears the entire playlist of all tracks
     
        NOTE - All playlist types will be affected by this operation. i.e. all playlist types will be cleared.
     */
    func clear()
}
