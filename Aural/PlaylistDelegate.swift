import Foundation

class PlaylistDelegate: PlaylistDelegateProtocol {
    
    private let mutator: PlaylistMutatorDelegateProtocol
    private let accessor: PlaylistAccessorDelegateProtocol
    
    init(_ mutator: PlaylistMutatorDelegateProtocol, _ accessor: PlaylistAccessorDelegateProtocol) {
        self.mutator = mutator
        self.accessor = accessor
    }
    
    func addFiles(_ files: [URL]) {
        mutator.addFiles(files)
    }
    
    func removeTrack(_ index: Int) {
        mutator.removeTrack(index)
    }
    
    func moveTrackUp(_ index: Int) -> Int {
        return mutator.moveTrackUp(index)
    }
    
    func moveTrackDown(_ index: Int) -> Int {
        return mutator.moveTrackDown(index)
    }
    
    func clear() {
        mutator.clear()
    }
    
    func sort(_ sort: Sort) {
        mutator.sort(sort)
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
    
    func savePlaylist(_ file: URL) {
        PlaylistIO.savePlaylist(file)
    }
}
