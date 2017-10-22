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
    
    func getTracks() -> [Track] {
        return accessor.getTracks()
    }
    
    func peekTrackAt(_ index: Int?) -> IndexedTrack? {
        return accessor.peekTrackAt(index)
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
    
    func search(_ searchQuery: SearchQuery) -> SearchResults {
        return accessor.search(searchQuery)
    }
    
    func addFiles(_ files: [URL]) {
        mutator.addFiles(files)
    }
    
    func removeTracks(_ indexes: [Int]) -> TrackRemoveResults {
        return mutator.removeTracks(indexes)
    }
    
    func removeTracksAndGroups(_ request: RemoveTracksAndGroupsRequest) {
        return mutator.removeTracksAndGroups(request)
    }
    
    func moveTracksUp(_ indexes: IndexSet) -> IndexSet {
        return mutator.moveTracksUp(indexes)
    }
    
    func moveTracksDown(_ indexes: IndexSet) -> IndexSet {
        return mutator.moveTracksDown(indexes)
    }
    
    func clear() {
        mutator.clear()
    }
    
    func sort(_ sort: Sort) {
        mutator.sort(sort)
    }
    
    func reorderTracks(_ reorderOperations: [PlaylistReorderOperation]) {
        mutator.reorderTracks(reorderOperations)
    }
    
    func savePlaylist(_ file: URL) {
        
        // Perform asynchronously, to unblock the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            PlaylistIO.savePlaylist(file)
        }
    }
    
    func getGroupingInfoForTrack(_ track: Track, _ groupType: GroupType) -> (group: Group, groupIndex: Int, trackIndex: Int) {
        
        return accessor.getGroupingInfoForTrack(track, groupType)
    }
}
