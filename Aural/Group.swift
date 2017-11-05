import Foundation

class Group: NSObject, GroupAccessorProtocol, GroupedPlaylistItem {
    
    let type: GroupType
    let name: String
    private var tracks: [Track] = [Track]()
    
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
    
    func size() -> Int {
        return tracks.count
    }
    
    func indexOfTrack(_ track: Track) -> Int? {
        return tracks.index(of: track)
    }
    
    func trackAtIndex(_ index: Int) -> Track {
        return tracks[index]
    }
    
    func insertTrackAtIndex(_ track: Track, _ index: Int) {
        tracks.insert(track, at: index)
    }
    
    func addTrack(_ track: Track) -> Int {
        
        var index: Int = -1
        
        ConcurrencyUtils.executeSynchronized(tracks) {
            tracks.append(track)
            index = tracks.count - 1
        }
        
        return index
    }
    
    func removeTrack(_ track: Track) -> Int {
        
        var trackIndex: Int = -1
        
        // TODO: Thread-safe ???
        ConcurrencyUtils.executeSynchronized(tracks) {
            
            if let index = tracks.index(of: track) {
                tracks.remove(at: index)
                trackIndex = index
            }
        }
        
        return trackIndex
    }
    
    func removeTrackAtIndex(_ index: Int) -> Track {
        return tracks.remove(at: index)
    }
    
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
        swap(&tracks[trackIndex1], &tracks[trackIndex2])
    }
    
    func sort(_ strategy: (Track, Track) -> Bool) {
        tracks.sort(by: strategy)
    }
}

enum GroupType: String {
    
    case artist
    case album
    case genre
    
    func toPlaylistType() -> PlaylistType {
        
        switch self {
            
        case .artist: return .artists
            
        case.album: return .albums
            
        case.genre: return .genres
            
        }
    }
}
