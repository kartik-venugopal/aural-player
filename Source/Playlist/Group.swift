import Foundation

/*
    Represents a group of tracks categorized by a certain property of the tracks - such as artist, album, or genre
 */
class Group: Hashable, PlaylistItem {
    
    let type: GroupType
    
    // The unique name of this group (either an artist, album, or genre name)
    let name: String
    
    // The tracks within this group
    private(set) var tracks: [Track] = []
    
    // Total duration of all tracks in this group
    var duration: Double {
        tracks.reduce(0.0, {(totalSoFar: Double, track: Track) -> Double in totalSoFar + track.duration})
    }
    
    init(_ type: GroupType, _ name: String) {
        
        self.type = type
        self.name = name
    }
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(type)
        hasher.combine(name)
    }
    
    // 2 Groups are equal if they are of the same type and have the same name.
    static func == (lhs: Group, rhs: Group) -> Bool {
        return (lhs.type == rhs.type) && (lhs.name == rhs.name)
    }
    
    func allTracks() -> [Track] {tracks}
    
    // Number of tracks
    var size: Int {tracks.count}
    
    func indexOfTrack(_ track: Track) -> Int? {
        return tracks.firstIndex(of: track)
    }
    
    func trackAtIndex(_ index: Int) -> Track? {
        return tracks.itemAtIndex(index)
    }
    
    func insertTrackAtIndex(_ track: Track, _ index: Int) {
        tracks.insert(track, at: index)
    }
    
    // Adds a track and returns the index of the new track
    func addTrack(_ track: Track) -> Int {
        return tracks.addItem(track)
    }
    
    // Removes a track at the given index, and returns the removed track
    func removeTrackAtIndex(_ index: Int) -> Track? {
        return tracks.removeItem(index)
    }
    
    func removeTracks(_ removedTracks: [Track]) -> IndexSet {
        return tracks.removeItems(removedTracks)
    }
    
    func moveTracksUp(_ tracksToMove: [Track]) -> [Int: Int] {
        return tracks.moveItemsUp(tracksToMove)
    }
    
    // Moves tracks within this group, at the given indexes, up one index, if possible. Returns a mapping of source indexes to destination indexes.
    func moveTracksUp(_ indices: IndexSet) -> [Int: Int] {
        return tracks.moveItemsUp(indices)
    }
    
    // Assume tracks can be moved
    func moveTracksToTop(_ indices: IndexSet) -> [Int: Int] {
        return tracks.moveItemsToTop(indices)
    }
    
    func moveTracksToTop(_ tracksToMove: [Track]) -> [Int: Int] {
        return tracks.moveItemsToTop(tracksToMove)
    }
    
    func moveTracksDown(_ tracksToMove: [Track]) -> [Int: Int] {
        return tracks.moveItemsDown(tracksToMove)
    }
    
    // Moves tracks within this group, at the given indexes, down one index, if possible. Returns a mapping of source indexes to destination indexes.
    func moveTracksDown(_ indices: IndexSet) -> [Int: Int] {
        return tracks.moveItemsDown(indices)
    }
    
    func moveTracksToBottom(_ tracksToMove: [Track]) -> [Int: Int] {
        return tracks.moveItemsToBottom(tracksToMove)
    }
    
    func moveTracksToBottom(_ indices: IndexSet) -> [Int: Int] {
        return tracks.moveItemsToBottom(indices)
    }
    
    func dragAndDropItems(_ sourceIndices: IndexSet, _ dropIndex: Int) -> [Int: Int] {
        return tracks.dragAndDropItems(sourceIndices, dropIndex)
    }
    
    // Sorts all tracks in this group, using the given strategy to compare tracks
    func sort(_ strategy: (Track, Track) -> Bool) {
        tracks.sort(by: strategy)
    }
    
    func indexOfTrack(for file: URL) -> Int? {
        return tracks.firstIndex(where: {$0.file == file})
    }
    
    func reOrder(accordingTo state: GroupState) {
        
        var insertionIndex: Int = 0
        
        for file in state.tracks {
            
            if let index = indexOfTrack(for: file) {
                
                if index != insertionIndex {
                    tracks.insert(tracks.remove(at: index), at: insertionIndex)
                }
                
                insertionIndex += 1
            }
        }
    }
}
