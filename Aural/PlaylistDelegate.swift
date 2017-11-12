import Foundation

/*
    Concrete implementation of PlaylistDelegateProtocol.
 */
class PlaylistDelegate: PlaylistDelegateProtocol {

    func findOrAddFile(_ file: URL) throws -> IndexedTrack {
        return try mutator.findOrAddFile(file)
    }

    func indexOfTrack(_ track: Track) -> IndexedTrack? {
        return accessor.indexOfTrack(track)
    }
    
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
    
    func size() -> Int {
        return accessor.size()
    }
    
    func totalDuration() -> Double {
        return accessor.totalDuration()
    }
    
    func summary(_ playlistType: PlaylistType) -> (size: Int, totalDuration: Double, numGroups: Int) {
        return accessor.summary(playlistType)
    }
    
    func search(_ searchQuery: SearchQuery, _ playlistType: PlaylistType) -> SearchResults {
        return accessor.search(searchQuery, playlistType)
    }
    
    func displayNameForTrack(_ playlistType: PlaylistType, _ track: Track) -> String {
        return accessor.displayNameForTrack(playlistType, track)
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
    
    func sort(_ sort: Sort, _ playlistType: PlaylistType) {
        mutator.sort(sort, playlistType)
    }
    
    func dropTracks(_ sourceIndexes: IndexSet, _ dropIndex: Int, _ dropType: DropType) -> IndexSet {
        return mutator.dropTracks(sourceIndexes, dropIndex, dropType)
    }
    
    func dropTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType, _ dropParent: Group?, _ dropIndex: Int) -> ItemMoveResults {
        
        return mutator.dropTracksAndGroups(tracks, groups, groupType, dropParent, dropIndex)
    }
    
    func savePlaylist(_ file: URL) {
        
        // Perform asynchronously, to unblock the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            PlaylistIO.savePlaylist(file)
        }
    }
}
