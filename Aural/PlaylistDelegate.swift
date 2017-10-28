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
    
    func getGroupingInfoForTrack(_ track: Track, _ groupType: GroupType) -> GroupedTrack {
        return accessor.getGroupingInfoForTrack(track, groupType)
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
    
    func search(_ searchQuery: SearchQuery, _ groupType: GroupType) -> SearchResults {
        return accessor.search(searchQuery, groupType)
    }
    
    func displayNameFor(_ type: GroupType, _ track: Track) -> String {
        return accessor.displayNameFor(type, track)
    }
    
    func getGroupAt(_ type: GroupType, _ index: Int) -> Group {
        return accessor.getGroupAt(type, index)
    }
    
    func getGroupingInfoForTrack(_ type: GroupType, _ track: Track) -> GroupedTrack {
        return accessor.getGroupingInfoForTrack(type, track)
    }
    
    func getIndexOf(_ group: Group) -> Int {
        return accessor.getIndexOf(group)
    }
    
    func getNumberOfGroups(_ type: GroupType) -> Int {
        return accessor.getNumberOfGroups(type)
    }
    
    func addFiles(_ files: [URL]) {
        mutator.addFiles(files)
    }
    
    func removeTracks(_ indexes: [Int]) {
        mutator.removeTracks(indexes)
    }
    
    func removeTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) {
        mutator.removeTracksAndGroups(tracks, groups, groupType)
    }
    
    func moveTracksUp(_ indexes: IndexSet) -> ItemMovedResults {
        return mutator.moveTracksUp(indexes)
    }
    
    func moveTracksDown(_ indexes: IndexSet) -> ItemMovedResults {
        return mutator.moveTracksDown(indexes)
    }
    
    func moveTracksAndGroupsUp(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMovedResults {
        return mutator.moveTracksAndGroupsUp(tracks, groups, groupType)
    }
    
    func moveTracksAndGroupsDown(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMovedResults {
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
    
    func reorderTracks(_ reorderOperations: [PlaylistReorderOperation]) {
        mutator.reorderTracks(reorderOperations)
    }
    
    func reorderTracks(_ reorderOperations: [GroupingPlaylistReorderOperation], _ groupType: GroupType) {
        mutator.reorderTracks(reorderOperations, groupType)
    }
    
    func savePlaylist(_ file: URL) {
        
        // Perform asynchronously, to unblock the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            PlaylistIO.savePlaylist(file)
        }
    }
}
