import Foundation
import AVFoundation

class FlatPlaylist: FlatPlaylistCRUDProtocol {
 
    private var tracks: [Track] = [Track]()
    
    func getTracks() -> [Track] {
        return tracks
    }
    
    func addTrackForIndex(_ track: Track) -> Int? {
        tracks.append(track)
        return tracks.count - 1
    }
    
    func clear() {
        tracks.removeAll()
    }
    
    // Returns all state for this playlist that needs to be persisted to disk
    func persistentState() -> PlaylistState {
        
        let state = PlaylistState()
        
        for track in tracks {
            state.tracks.append(track.file)
        }
        
        return state
    }
 
    func peekTrackAt(_ index: Int?) -> IndexedTrack? {
        let invalidIndex: Bool = index == nil || index! < 0 || index! >= tracks.count
        return invalidIndex ? nil : IndexedTrack(tracks[index!], index!)
    }
    
    private func removeTrack(_ index: Int) -> Track {
        return tracks.remove(at: index)
    }
    
    private func removeTrack(_ track: Track) -> Int? {
        
        if let index = indexOfTrack(track) {
            tracks.remove(at: index)
            return index
        }
        
        return nil
    }
    
    func removeTracks(_ removedTracks: [Track]) -> IndexSet {
        
        var trackIndexes = [Int]()
        
        removedTracks.forEach({trackIndexes.append(indexOfTrack($0)!)})
        
        trackIndexes = trackIndexes.sorted(by: {i1, i2 -> Bool in return i1 > i2})
        
        trackIndexes.forEach({_ = removeTrack($0)})
        
        return IndexSet(trackIndexes)
    }
    
    func removeTracks(_ indexes: IndexSet) -> [Track] {
        
        // Need to remove tracks in descending order of index, so that indexes of yet-to-be-removed elements are not messed up
        
        // Sort descending
        let sortedIndexes = indexes.sorted(by: {x, y -> Bool in x > y})
        
        // TODO: Will forEach always iterate array in order ??? If not, cannot use it. Array needs to be iterated in exact order.
        
        var rt = [Track]()
        sortedIndexes.forEach({rt.append(removeTrack($0))})
        
        return rt
    }
    
    func indexOfTrack(_ track: Track) -> Int?  {
        return tracks.index(of: track)
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
    
    // Swaps two tracks in the array of tracks
    private func swapTracks(_ trackIndex1: Int, _ trackIndex2: Int) {
        swap(&tracks[trackIndex1], &tracks[trackIndex2])
    }
    
    func reorderTracks(_ reorderOperations: [PlaylistReorderOperation]) {
        
        // Perform all operations in sequence
        for op in reorderOperations {
            
            // Check which kind of operation this is, and perform it
            if let copyOp = op as? PlaylistCopyOperation {
                
                tracks[copyOp.destIndex] = tracks[copyOp.srcIndex]
                
            } else if let overwriteOp = op as? PlaylistOverwriteOperation {
                
                tracks[overwriteOp.destIndex] = overwriteOp.srcTrack
            }
        }
    }
 
    func search(_ searchQuery: SearchQuery) -> SearchResults {
        
        var results: [SearchResult] = [SearchResult]()
        var resultIndex = 1
        
        for i in 0...tracks.count - 1 {
            
            let track = tracks[i]
            let match = trackMatchesQuery(track: track, searchQuery: searchQuery)
            
            if (match.matched) {
                results.append(SearchResult(resultIndex: resultIndex, trackIndex: i, match: (match.matchedField!, match.matchedFieldValue!)))
                resultIndex += 1
            }
        }
        
        return SearchResults(results: results)
    }
    
    // Checks if a single track matches search criteria, and returns information about the match, if there is one
    private func trackMatchesQuery(track: Track, searchQuery: SearchQuery) -> (matched: Bool, matchedField: String?, matchedFieldValue: String?) {
        
        // Add name field if included in search
        if (searchQuery.fields.name) {
            
            // Check both the filename and the display name
            
            let lastPathComponent = track.file.deletingPathExtension().lastPathComponent
            if (compare(lastPathComponent, searchQuery)) {
                return (true, "filename", lastPathComponent)
            }
            
            let displayName = track.conciseDisplayName
            if (compare(displayName, searchQuery)) {
                return (true, "name", displayName)
            }
        }
        
        // Add artist field if included in search
        if (searchQuery.fields.artist) {
            
            if let artist = track.displayInfo.artist {
                
                if (compare(artist, searchQuery)) {
                    return (true, "artist", artist)
                }
            }
        }
        
        // Add title field if included in search
        if (searchQuery.fields.title) {
            
            if let title = track.displayInfo.title {
                
                if (compare(title, searchQuery)) {
                    return (true, "title", title)
                }
            }
        }
        
        // Add album field if included in search
        if (searchQuery.fields.album) {
            
            // Make sure album info has been loaded (it is loaded lazily)
            MetadataReader.loadSearchMetadata(track)
            
            if let album = track.metadata[AVMetadataCommonKeyAlbumName]?.value {
                
                if (compare(album, searchQuery)) {
                    return (true, "album", album)
                }
            }
        }
        
        // Didn't match
        return (false, nil, nil)
    }
    
    private func compare(_ fieldVal: String, _ query: SearchQuery) -> Bool {
        
        let caseSensitive: Bool = query.options.caseSensitive
        let queryText: String = caseSensitive ? query.text : query.text.lowercased()
        let compared: String = caseSensitive ? fieldVal : fieldVal.lowercased()
        let type: SearchType = query.type
        
        switch type {
            
        case .beginsWith: return compared.hasPrefix(queryText)
            
        case .endsWith: return compared.hasSuffix(queryText)
            
        case .equals: return compared == queryText
            
        case .contains: return compared.contains(queryText)
            
        }
    }
    
    func sort(_ sort: Sort) {
        
        switch sort.field {
            
        // Sort by name
        case .name: if sort.order == SortOrder.ascending {
            tracks.sort(by: compareTracks_ascendingByName)
        } else {
            tracks.sort(by: compareTracks_descendingByName)
            }
            
        // Sort by duration
        case .duration: if sort.order == SortOrder.ascending {
            tracks.sort(by: compareTracks_ascendingByDuration)
        } else {
            tracks.sort(by: compareTracks_descendingByDuration)
            }
        }
    }
    
    // Comparison functions for different sort criteria
    
    private func compareTracks_ascendingByName(aTrack: Track, anotherTrack: Track) -> Bool {
        return aTrack.conciseDisplayName.compare(anotherTrack.conciseDisplayName) == ComparisonResult.orderedAscending
    }
    
    private func compareTracks_descendingByName(aTrack: Track, anotherTrack: Track) -> Bool {
        return aTrack.conciseDisplayName.compare(anotherTrack.conciseDisplayName) == ComparisonResult.orderedDescending
    }
    
    private func compareTracks_ascendingByDuration(aTrack: Track, anotherTrack: Track) -> Bool {
        return aTrack.duration < anotherTrack.duration
    }
    
    private func compareTracks_descendingByDuration(aTrack: Track, anotherTrack: Track) -> Bool {
        return aTrack.duration > anotherTrack.duration
    }
}
