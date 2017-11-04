import Foundation

/*
    Concrete implementation of PlaylistDelegateProtocol.
 */
class PlaylistDelegate: PlaylistDelegateProtocol {
    
    // Accessor delegate, to which all read-only operations are deferred
    private let accessor: PlaylistAccessorDelegateProtocol
    
    // Mutator delegate, to which all mutating/write operations are deferred
    private let mutator: PlaylistMutatorDelegateProtocol
    
    init(_ accessor: PlaylistAccessorDelegateProtocol, _ mutator: PlaylistMutatorDelegateProtocol) {
        self.accessor = accessor
        self.mutator = mutator
    }
    
    func allTracks() -> [Track] {
        return accessor.allTracks()
    }
    
    func trackAtIndex(_ index: Int?) -> IndexedTrack? {
        return accessor.trackAtIndex(index)
    }
    
    func groupingInfoForTrack(_ track: Track, _ groupType: GroupType) -> GroupedTrack {
        return accessor.groupingInfoForTrack(track, groupType)
    }
    
    func size() -> Int {
        return accessor.size()
    }
    
    func totalDuration() -> Double {
        return accessor.totalDuration()
    }
    
    func summary() -> (size: Int, totalDuration: Double) {
        return accessor.summary()
    }
    
    func summary(_ groupType: GroupType) -> (size: Int, totalDuration: Double, numGroups: Int) {
        return accessor.summary(groupType)
    }
    
    func search(_ searchQuery: SearchQuery) -> SearchResults {
        return accessor.search(searchQuery)
    }
    
    func search(_ searchQuery: SearchQuery, _ groupType: GroupType) -> SearchResults {
        return accessor.search(searchQuery, groupType)
    }
    
    func displayNameForTrack(_ type: GroupType, _ track: Track) -> String {
        return accessor.displayNameForTrack(type, track)
    }
    
    func groupAtIndex(_ type: GroupType, _ index: Int) -> Group {
        return accessor.groupAtIndex(type, index)
    }
    
    func groupingInfoForTrack(_ type: GroupType, _ track: Track) -> GroupedTrack {
        return accessor.groupingInfoForTrack(type, track)
    }
    
    func indexOfGroup(_ group: Group) -> Int {
        return accessor.indexOfGroup(group)
    }
    
    func numberOfGroups(_ type: GroupType) -> Int {
        return accessor.numberOfGroups(type)
    }
    
    func addFiles(_ files: [URL]) {
        mutator.addFiles(files)
    }
    
    func removeTracks(_ indexes: IndexSet) {
        return mutator.removeTracks(indexes)
    }
    
    func removeTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) {
        mutator.removeTracksAndGroups(tracks, groups, groupType)
    }
    
    func moveTracksUp(_ indexes: IndexSet) -> ItemMoveResults {
        return mutator.moveTracksUp(indexes)
    }
    
    func moveTracksDown(_ indexes: IndexSet) -> ItemMoveResults {
        return mutator.moveTracksDown(indexes)
    }
    
    func moveTracksAndGroupsUp(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults {
        return mutator.moveTracksAndGroupsUp(tracks, groups, groupType)
    }
    
    func moveTracksAndGroupsDown(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults {
        return mutator.moveTracksAndGroupsDown(tracks, groups, groupType)
    }

    func clear() {
        mutator.clear()
    }
    
    func sort(_ sort: Sort) {
        mutator.sort(sort)
    }
    
    func sort(_ sort: Sort, _ groupType: GroupType) {
        mutator.sort(sort, groupType)
    }
    
    func reorderTracks(_ reorderOperations: [FlatPlaylistReorderOperation]) {
        mutator.reorderTracks(reorderOperations)
    }
    
    func reorderTracksAndGroups(_ reorderOperations: [GroupingPlaylistReorderOperation], _ groupType: GroupType) {
        mutator.reorderTracksAndGroups(reorderOperations, groupType)
    }
    
    func savePlaylist(_ file: URL) {
        
        // Perform asynchronously, to unblock the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            PlaylistIO.savePlaylist(file)
        }
    }
}
