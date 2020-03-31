import Foundation

/*
    Represents a group of tracks categorized by a certain property of the tracks - such as artist, album, or genre
 */
class Group: NSObject, GroupAccessorProtocol, PlaylistItem {
    
    let type: GroupType
    
    // The unique name of this group (either an artist, album, or genre name)
    let name: String
    
    // The tracks within this group
    private var tracks: [Track] = [Track]()
    
    // Total duration of all tracks in this group
    var duration: Double {
        
        var totalDuration: Double = 0
        tracks.forEach({totalDuration += $0.duration})
        return totalDuration
    }
    
    init(_ type: GroupType, _ name: String) {
        self.type = type
        self.name = name
    }
    
    func allTracks() -> [Track] {
        
        // Return a copy
        let allTracks = tracks
        return allTracks
    }
    
    // Number of tracks
    func size() -> Int {
        return tracks.count
    }
    
    func indexOfTrack(_ track: Track) -> Int? {
        return tracks.firstIndex(of: track)
    }
    
    func trackAtIndex(_ index: Int) -> Track {
        return tracks[index]
    }
    
    func insertTrackAtIndex(_ track: Track, _ index: Int) {
        tracks.insert(track, at: index)
    }
    
    // Adds a track and returns the index of the new track
    func addTrack(_ track: Track) -> Int {
        
        tracks.append(track)
        return tracks.count - 1
    }
    
    // Removes a track at the given index, and returns the removed track
    func removeTrackAtIndex(_ index: Int) -> Track {
        return tracks.remove(at: index)
    }
    
    // Moves tracks within this group, at the given indexes, up one index, if possible. Returns a mapping of source indexes to destination indexes.
    func moveTracksUp(_ indexes: IndexSet) -> [Int: Int] {
        
        // Indexes need to be in ascending order, because tracks need to be moved up, one by one, from top to bottom of the playlist
        let ascendingOldIndexes = indexes.sorted(by: {x, y -> Bool in x < y})
        
        // Mappings of oldIndex (prior to move) -> newIndex (after move)
        var indexMappings = [Int: Int]()
        
        // Determine if there is a contiguous block of tracks at the top of the playlist, that cannot be moved. If there is, determine its size. At the end of the loop, the cursor's value will equal the size of the block.
        var unmovableBlockCursor = 0
        while (ascendingOldIndexes.contains(unmovableBlockCursor)) {
            
            // Since this track cannot be moved, map its old index to the same old index
            indexMappings[unmovableBlockCursor] = unmovableBlockCursor
            unmovableBlockCursor += 1
        }
        
        // If there are any tracks that can be moved, move them and store the index mappings
        if (unmovableBlockCursor < ascendingOldIndexes.count) {
            
            for index in unmovableBlockCursor...ascendingOldIndexes.count - 1 {
                indexMappings[ascendingOldIndexes[index]] = moveTrackUp(ascendingOldIndexes[index])
            }
        }
        
        return indexMappings
    }
    
    // Assume tracks can be moved
    func moveTracksToTop(_ indexes: IndexSet) -> [Int: Int] {
        
        var tracksMoved: Int = 0
        let sortedIndexes = indexes.sorted(by: {x, y -> Bool in x < y})
        
        // Mappings of oldIndex (prior to move) -> newIndex (after move)
        var indexMappings = [Int: Int]()
        
        for index in sortedIndexes {
            
            // Remove from original location and insert at top, one after another, below the previous one
            let track = tracks.remove(at: index)
            tracks.insert(track, at: tracksMoved)
            
            indexMappings[index] = tracksMoved
            
            tracksMoved += 1
        }
        
        return indexMappings
    }
    
    // Moves tracks within this group, at the given indexes, down one index, if possible. Returns a mapping of source indexes to destination indexes.
    func moveTracksDown(_ indexes: IndexSet) -> [Int: Int] {
        
        // Indexes need to be in descending order, because tracks need to be moved down, one by one, from bottom to top of the playlist
        let descendingOldIndexes = indexes.sorted(by: {x, y -> Bool in x > y})
        
        // Mappings of oldIndex (prior to move) -> newIndex (after move)
        var indexMappings = [Int: Int]()
        
        // Determine if there is a contiguous block of tracks at the top of the playlist, that cannot be moved. If there is, determine its size.
        var unmovableBlockCursor = tracks.count - 1
        
        // Tracks the size of the unmovable block. At the end of the loop, the variable's value will equal the size of the block.
        var unmovableBlockSize = 0
        
        while (descendingOldIndexes.contains(unmovableBlockCursor)) {
            
            // Since this track cannot be moved, map its old index to the same old index
            indexMappings[unmovableBlockCursor] = unmovableBlockCursor
            unmovableBlockCursor -= 1
            unmovableBlockSize += 1
        }
        
        // If there are any tracks that can be moved, move them and store the index mappings
        if (unmovableBlockSize < descendingOldIndexes.count) {
            
            for index in unmovableBlockSize...descendingOldIndexes.count - 1 {
                indexMappings[descendingOldIndexes[index]] = moveTrackDown(descendingOldIndexes[index])
            }
        }
        
        return indexMappings
    }
    
    func moveTracksToBottom(_ indexes: IndexSet) -> [Int: Int] {
        
        var tracksMoved: Int = 0
        let sortedIndexes = indexes.sorted(by: {x, y -> Bool in x > y})
        
        // Mappings of oldIndex (prior to move) -> newIndex (after move)
        var indexMappings = [Int: Int]()
        
        for index in sortedIndexes {
            
            // Remove from original location and insert at top, one after another, below the previous one
            let track = tracks.remove(at: index)
            
            let newIndex = tracks.endIndex - tracksMoved
            tracks.insert(track, at: newIndex)
            
            indexMappings[index] = newIndex
            
            tracksMoved += 1
        }
        
        return indexMappings
    }
    
    // Assume track can be moved
    private func moveTrackUp(_ index: Int) -> Int {
        
        let upIndex = index - 1
        swapTracks(index, upIndex)
        return upIndex
    }
    
    // Assume track can be moved
    private func moveTrackDown(_ index: Int) -> Int {
        
        let downIndex = index + 1
        swapTracks(index, downIndex)
        return downIndex
    }
    
    // Swaps two tracks in the array of tracks
    private func swapTracks(_ trackIndex1: Int, _ trackIndex2: Int) {
        
        let temp = tracks[trackIndex1]
        tracks[trackIndex1] = tracks[trackIndex2]
        tracks[trackIndex2] = temp
    }
    
    // Sorts all tracks in this group, using the given strategy to compare tracks
    func sort(_ strategy: (Track, Track) -> Bool) {
        tracks.sort(by: strategy)
    }
}
