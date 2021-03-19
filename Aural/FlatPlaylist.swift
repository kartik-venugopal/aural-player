import Foundation

/*
    The flat playlist is a non-hierarchical playlist, in which tracks are arranged in a linear fashion, and in which each track is a top-level item and can be located with just an index.
 */
class FlatPlaylist: FlatPlaylistCRUDProtocol {
 
    var tracks: [Track] = [Track]()
    
    // MARK: Accessor functions
    
    var size: Int {return tracks.count}
    
    var duration: Double {
        
        var totalDuration: Double = 0
        tracks.forEach({totalDuration += $0.duration})
        return totalDuration
    }
    
    func displayNameForTrack(_ track: Track) -> String {
        return track.conciseDisplayName
    }
    
    func trackAtIndex(_ index: Int?) -> IndexedTrack? {
        let invalidIndex: Bool = index == nil || index! < 0 || index! >= tracks.count
        return invalidIndex ? nil : IndexedTrack(tracks[index!], index!)
    }
    
    func indexOfTrack(_ track: Track) -> Int?  {
        return tracks.firstIndex(of: track)
    }
    
    func search(_ searchQuery: SearchQuery) -> SearchResults {
        
        var results: [SearchResult] = [SearchResult]()
        
        // Iterate through all tracks
        tracks.forEach({
            
            // Check if this track matches the search query
            let match = trackMatchesQuery($0, searchQuery)
            
            // If there was a match, append the result to the set of results
            if (match.matched) {
                
                // Track index will be determined later, if required
                results.append(SearchResult(location: SearchResultLocation(trackIndex: -1, track: $0, groupInfo: nil), match: (match.matchedField!, match.matchedFieldValue!)))
            }
        })
        
        return SearchResults(results)
    }
    
    // Checks if a single track matches search criteria, and returns information about the match, if there is one
    private func trackMatchesQuery(_ track: Track, _ searchQuery: SearchQuery) -> (matched: Bool, matchedField: String?, matchedFieldValue: String?) {
        
        // Compare name field if included in search
        if (searchQuery.fields.name) {
            
            // Check both the filename and the display name
            
            let filename = track.file.deletingPathExtension().lastPathComponent
            if (compare(filename, searchQuery)) {
                return (true, "filename", filename)
            }
            
            let displayName = track.conciseDisplayName
            if (compare(displayName, searchQuery)) {
                return (true, "name", displayName)
            }
        }
        
        // Compare title field if included in search
        if (searchQuery.fields.title) {
            
            if let title = track.displayInfo.title {
                
                if (compare(title, searchQuery)) {
                    return (true, "title", title)
                }
            }
        }
        
        // Didn't match
        return (false, nil, nil)
    }
    
    // Helper function that compares the value of a single field to the search text to determine if there is a match
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
    
    // MARK: Mutator functions
    
    func addTrack(_ track: Track) -> Int {
        tracks.append(track)
        return tracks.count - 1
    }
    
    func clear() {
        tracks.removeAll()
    }
 
    private func removeTrackAtIndex(_ index: Int) -> Track {
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
        
        // Collect the indexes of each of the tracks being removed
        removedTracks.forEach({trackIndexes.append(indexOfTrack($0)!)})
        
        // Sort the indexes in descending order (tracks need to be removed in descending order)
        trackIndexes = trackIndexes.sorted(by: {i1, i2 -> Bool in return i1 > i2})
        
        // Remove the tracks at the indexes
        trackIndexes.forEach({_ = removeTrackAtIndex($0)})
        
        return IndexSet(trackIndexes)
    }
    
    func removeTracks(_ indexes: IndexSet) -> [Track] {
        
        // Need to remove tracks in descending order of index, so that indexes of yet-to-be-removed elements are not messed up
        
        // Sort descending
        let sortedIndexes = indexes.sorted(by: {x, y -> Bool in x > y})
        
        // Collect the tracks as they are removed
        var removedTracks = [Track]()
        sortedIndexes.forEach({removedTracks.append(removeTrackAtIndex($0))})
        
        return removedTracks
    }
    
    // Assume track can be moved
    private func moveTrackUp(_ index: Int) -> Int {
        
        let upIndex = index - 1
        swapTracks(index, upIndex)
        return upIndex
    }
    
    // Assume tracks can be moved
    func moveTracksToTop(_ indexes: IndexSet) -> ItemMoveResults {
        
        var tracksMoved: Int = 0
        let sortedIndexes = indexes.sorted(by: {x, y -> Bool in x < y})
        
        var results = [TrackMoveResult]()
        
        for index in sortedIndexes {
            
            // Remove from original location and insert at top, one after another, below the previous one
            let track = tracks.remove(at: index)
            tracks.insert(track, at: tracksMoved)
            
            results.append(TrackMoveResult(index, tracksMoved))
            
            tracksMoved += 1
        }
        
        // Ascending order (by old index)
        return ItemMoveResults(results.sorted(by: {r1, r2 -> Bool in return r1.sortIndex < r2.sortIndex}), .tracks)
    }
    
    func moveTracksToBottom(_ indexes: IndexSet) -> ItemMoveResults {
        
        var tracksMoved: Int = 0
        let sortedIndexes = indexes.sorted(by: {x, y -> Bool in x > y})
        
        var results = [TrackMoveResult]()
        
        for index in sortedIndexes {
            
            // Remove from original location and insert at top, one after another, below the previous one
            let track = tracks.remove(at: index)
            
            let newIndex = tracks.endIndex - tracksMoved
            tracks.insert(track, at: newIndex)
            
            results.append(TrackMoveResult(index, newIndex))
            
            tracksMoved += 1
        }
        
        // Descending order (by old index)
        return ItemMoveResults(results.sorted(by: {r1, r2 -> Bool in return r1.sortIndex > r2.sortIndex}), .tracks)
    }
    
    // Assume track can be moved
    private func moveTrackDown(_ index: Int) -> Int {
        
        let downIndex = index + 1
        swapTracks(index, downIndex)
        return downIndex
    }
    
    func moveTracksUp(_ indexes: IndexSet) -> ItemMoveResults {
        
        // Indexes need to be in ascending order, because tracks need to be moved up, one by one, from top to bottom of the playlist
        let ascendingOldIndexes = indexes.sorted(by: {x, y -> Bool in x < y})
        
        // Mappings of oldIndex (prior to move) -> newIndex (after move)
        var results = [TrackMoveResult]()
        
        // Determine if there is a contiguous block of tracks at the top of the playlist, that cannot be moved. If there is, determine its size. At the end of the loop, the cursor's value will equal the size of the block.
        var unmovableBlockCursor = 0
        while (ascendingOldIndexes.contains(unmovableBlockCursor)) {
            
            // Since this track cannot be moved, map its old index to the same old index
            unmovableBlockCursor += 1
        }
        
        // If there are any tracks that can be moved, move them and store the index mappings
        if (unmovableBlockCursor < ascendingOldIndexes.count) {
            
            for index in unmovableBlockCursor...ascendingOldIndexes.count - 1 {
                
                let oldIndex = ascendingOldIndexes[index]
                let newIndex = moveTrackUp(oldIndex)
                results.append(TrackMoveResult(oldIndex, newIndex))
            }
        }
        
        // Ascending order (by old index)
        return ItemMoveResults(results.sorted(by: {r1, r2 -> Bool in return r1.sortIndex < r2.sortIndex}), .tracks)
    }
    
    func moveTracksDown(_ indexes: IndexSet) -> ItemMoveResults {
        
        // Indexes need to be in descending order, because tracks need to be moved down, one by one, from bottom to top of the playlist
        let descendingOldIndexes = indexes.sorted(by: {x, y -> Bool in x > y})
        
        // Mappings of oldIndex (prior to move) -> newIndex (after move)
        var results = [TrackMoveResult]()
        
        // Determine if there is a contiguous block of tracks at the top of the playlist, that cannot be moved. If there is, determine its size.
        var unmovableBlockCursor = tracks.count - 1
        
        // Tracks the size of the unmovable block. At the end of the loop, the variable's value will equal the size of the block.
        var unmovableBlockSize = 0
        
        while (descendingOldIndexes.contains(unmovableBlockCursor)) {
            
            // Since this track cannot be moved, map its old index to the same old index
            unmovableBlockCursor -= 1
            unmovableBlockSize += 1
        }
        
        // If there are any tracks that can be moved, move them and store the index mappings
        if (unmovableBlockSize < descendingOldIndexes.count) {
            
            for index in unmovableBlockSize...descendingOldIndexes.count - 1 {
                
                let oldIndex = descendingOldIndexes[index]
                let newIndex = moveTrackDown(oldIndex)
                results.append(TrackMoveResult(oldIndex, newIndex))
            }
        }
        
        // Descending order (by old index)
        return ItemMoveResults(results.sorted(by: {r1, r2 -> Bool in return r1.sortIndex > r2.sortIndex}), .tracks)
    }
    
    // Swaps two tracks in the array of tracks
    private func swapTracks(_ trackIndex1: Int, _ trackIndex2: Int) {

        let temp = tracks[trackIndex1]
        tracks[trackIndex1] = tracks[trackIndex2]
        tracks[trackIndex2] = temp
    }
 
    func sort(_ sort: Sort) {
        
        if sort.tracksSort != nil {
            tracks.sort(by: SortComparator(sort, self.displayNameForTrack).compareTracks)
        }
    }
    
    func dropTracks(_ sourceIndexes: IndexSet, _ dropIndex: Int, _ dropType: DropType) -> IndexSet {
        
        let destination = calculateReorderingDestination(sourceIndexes, dropIndex, dropType)
        performReordering(sourceIndexes, destination)
        return destination
    }
    
    /*
        In response to a playlist reordering by drag and drop, and given source indexes, a destination index, and the drop operation (on/above), determines which destination indexes the source indexs will occupy.
     */
    private func calculateReorderingDestination(_ sourceIndexSet: IndexSet, _ dropIndex: Int, _ dropType: DropType) -> IndexSet {
        
        // Find out how many source items are above the dropIndex and how many below
        let sourceIndexesAboveDropIndex = sourceIndexSet.count(in: 0..<dropIndex)
        let sourceIndexesBelowDropIndex = sourceIndexSet.count - sourceIndexesAboveDropIndex
        
        // The lowest index in the destination indexes
        var minDestinationIndex: Int
        
        // The highest index in the destination indexes
        var maxDestinationIndex: Int
        
        // The destination indexes will depend on whether the drop is to be performed above or on the dropIndex
        if (dropType == .above) {
            
            // All source items above the dropIndex will form a contiguous block ending just above (one index above) the dropIndex
            // All source items below the dropIndex will form a contiguous block starting at the dropIndex and extending below it
            
            minDestinationIndex = dropIndex - sourceIndexesAboveDropIndex
            maxDestinationIndex = dropIndex + sourceIndexesBelowDropIndex - 1
            
        } else {
            
            // On
            
            // If the drop is being performed on the dropIndex, the destination indexes will further depend on whether there are more source items above or below the dropIndex.
            if (sourceIndexesAboveDropIndex > sourceIndexesBelowDropIndex) {
                
                // There are more source items above the dropIndex than below it
                
                // All source items above the dropIndex will form a contiguous block ending at the dropIndex
                // All source items below the dropIndex will form a contiguous block starting one index below the dropIndex and extending below it
                
                minDestinationIndex = dropIndex - sourceIndexesAboveDropIndex + 1
                maxDestinationIndex = dropIndex + sourceIndexesBelowDropIndex
                
            } else {
                
                // There are more source items below the dropIndex than above it
                
                // All source items above the dropIndex will form a contiguous block ending just above (one index above) the dropIndex
                // All source items below the dropIndex will form a contiguous block starting at the dropIndex and extending below it
                
                minDestinationIndex = dropIndex - sourceIndexesAboveDropIndex
                maxDestinationIndex = dropIndex + sourceIndexesBelowDropIndex - 1
            }
        }
        
        return IndexSet(minDestinationIndex...maxDestinationIndex)
    }
    
    /*
        Performs a playlist reordering (drag n drop)
     */
    private func performReordering(_ sourceIndexes: IndexSet, _ destinationIndexes: IndexSet) {
        
        // Store all source items (tracks) that are being reordered, in a temporary location.
        var sourceItems = [Track]()
        
        // Make sure they the source indexes are iterated in descending order, because tracks need to be removed from the bottom up.
        sourceIndexes.sorted(by: {x, y -> Bool in x > y}).forEach({
            
            // Remove the track at this index and collect it
            sourceItems.append(tracks.remove(at: $0))
        })
        
        var cursor = 0
        
        // Destination indexes need to be sorted in ascending order, because tracks need to be inserted from the top down
        let destinationIndexes = destinationIndexes.sorted(by: {x, y -> Bool in x < y})
        
        // Reverse the source items collection to match the order of the destination indexes
        sourceItems = sourceItems.reversed()
        
        destinationIndexes.forEach({
            
            // For each destination index, copy over a source item into the corresponding destination hole
            tracks.insert(sourceItems[cursor], at: $0)
            cursor += 1
        })
    }
}
