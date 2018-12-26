import Cocoa

/*
    Contract for a middleman/delegate that relays mutating/write operations to the playlist
 */
protocol PlaylistMutatorDelegateProtocol {
    
    /* 
        Adds a set of files to the playlist, asynchronously, if they are valid and supported by the app.
     
        Each of the files can be one of the following:
        1 - A valid audio file with a supported format
        2 - A supported playlist file
        3 - A directory
     
        All playlist files are expanded into their constituent tracks.
        All directories are traversed recursively, and all supported files within them are added in turn.
     
        NOTE:
     
            - Duplicates are omitted (if a file already exists in the playlist, it will not be added).
     
            - All playlist types will be affected by this operation. i.e. the tracks will be added to all playlist types.
     */
    func addFiles(_ files: [URL])
    
    // Searches for a track by file. If it is found, its information is returned. If not, it is first added and then its information is returned. Throws an error if the file does not exist on the filesystem.
    func findOrAddFile(_ file: URL) throws -> IndexedTrack?
    
    /*
        Removes track(s) with the given indexes within the flat playlist.
     
        NOTE - All playlist types will be affected by this operation. i.e. the tracks will be removed from all playlist types.
    */
    func removeTracks(_ indexes: IndexSet)
    
    /*
        Given a set of tracks and groups, removes them from the playlist. Removal of all tracks within a group will result in the removal of the group. Removal of a group will result in the removal of all its child tracks. The groupType argument indicates the type of the groups in the groups argument.
     
        NOTE - All playlist types will be affected by this operation. i.e. the removed tracks will be removed from all playlist types.
     */
    func removeTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType)
    
    /*
        Clears the entire playlist of all tracks
     
        NOTE - All playlist types will be affected by this operation. i.e. all playlist types will be cleared.
    */
    func clear()
    
    func setGapsForTrack(_ track: Track, _ gapBeforeTrack: PlaybackGap?, _ gapAfterTrack: PlaybackGap?)
    
    func removeGapsForTrack(_ track: Track)
    
    /*
        Moves the tracks at the specified indexes, up one index, in the flat playlist, if they can be moved (they are not already at the top). Returns mappings of source indexes to destination indexes, for all the tracks (for tracks that didn't move, the new index will match the old index)
    
        NOTE:
     
            - Even if some tracks cannot move, those that can will be moved. i.e. This is not an all or nothing operation.
     
            - Only the flat playlist will be altered. The other playlist types will be unaffected by this operation. Each playlist type's sequence of tracks/groups is independent from that of all other playlist types.
    */
    func moveTracksUp(_ indexes: IndexSet) -> ItemMoveResults
    
    func moveTracksToTop(_ indexes: IndexSet) -> ItemMoveResults
    
    /*
        Moves the tracks at the specified indexes, down one index, in the flat playlist, if they can be moved (they are not already at the bottom). Returns mappings of source indexes to destination indexes, for all the tracks (for tracks that didn't move, the new index will match the old index)
     
        NOTE:
     
            - Even if some tracks cannot move, those that can will be moved. i.e. This is not an all or nothing operation.
     
            - Only the flat playlist will be altered. The other playlist types will be unaffected by this operation. Each playlist type's sequence of tracks/groups is independent from that of all other playlist types.
     */
    func moveTracksDown(_ indexes: IndexSet) -> ItemMoveResults
    
    func moveTracksToBottom(_ indexes: IndexSet) -> ItemMoveResults
    
    /*
        Moves either the specified tracks, or the specified groups (groups take precedence), up one index in the specified grouping/hierarchical playlist type, if they can be moved (they are not already at the top). Returns mappings of source indexes to destination indexes, for all the tracks/groups (for tracks/groups that didn't move, the new index will match the old index).
     
        NOTE:
     
            - If both tracks and groups are specified, only the groups will be moved.
     
            - Even if some tracks/groups cannot move, those that can will be moved. i.e. This is not an all or nothing operation.
     
            - Only the specified type of grouping/hierarchical playlist will be altered. The other playlist types will be unaffected by this operation. Each playlist type's sequence of tracks/groups is independent from that of all other playlist types.
     */
    func moveTracksAndGroupsUp(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults
    
    func moveTracksAndGroupsToTop(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults
    
    /*
        Moves either the specified tracks, or the specified groups (groups take precedence), down one index in the specified grouping/hierarchical playlist type, if they can be moved (they are not already at the bottom). Returns mappings of source indexes to destination indexes, for all the tracks/groups (for tracks/groups that didn't move, the new index will match the old index).
     
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
    func sort(_ sort: Sort, _ playlistType: PlaylistType)
    
    /*
        Performs a drag and drop reordering operation on the flat playlist, from a set of source indexes to a destination drop index (either on or above the drop index). Returns the set of new destination indexes for the reordered items.
     
        NOTE: Only the flat playlist will be altered. The other playlist types will be unaffected by this operation. Each playlist type's sequence of tracks/groups is independent from that of all other playlist types.
    */
    func dropTracks(_ sourceIndexes: IndexSet, _ dropIndex: Int, _ dropType: DropType) -> IndexSet
    
    /*
        Performs a drag and drop reordering operation on a specific grouping/hierarchical playlist. Source items (tracks or groups) are dropped, under a given parent (either the root, if groups are being moved, or a specific group, if tracks are being moved), at a destination drop index. Returns mappings of source locations to destination locations.
     
        NOTE:
     
            - If both tracks and groups are specified, only the groups will be moved.
     
            - Only the specified type of grouping/hierarchical playlist will be altered. The other playlist types will be unaffected by this operation. Each playlist type's sequence of tracks/groups is independent from that of all other playlist types.
     */
    func dropTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType, _ dropParent: Group?, _ dropIndex: Int) -> ItemMoveResults
}
