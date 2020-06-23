import Foundation

/*
    The flat playlist is a non-hierarchical playlist, in which tracks are arranged in a linear fashion, and in which each track is a top-level item and can be located with just an index.
 */
class FlatPlaylist: FlatPlaylistCRUDProtocol {
 
    var tracks: [Track] = [Track]()
    
    // MARK: Accessor functions
    
    var size: Int {tracks.count}
    
    var duration: Double {
        return tracks.reduce(0.0, {(totalSoFar: Double, track: Track) -> Double in totalSoFar + track.duration})
    }
    
    func displayNameForTrack(_ track: Track) -> String {
        return track.conciseDisplayName
    }
    
    func trackAtIndex(_ index: Int) -> Track? {
        return optionalIndexedOperation(index, {tracks[index]})
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
            if match.matched, let matchedField = match.matchedField, let matchedFieldValue = match.matchedFieldValue {
                
                // Track index will be determined later, if required
                results.append(SearchResult(location: SearchResultLocation(trackIndex: -1, track: $0, groupInfo: nil), match: (matchedField, matchedFieldValue)))
            }
        })
        
        return SearchResults(results)
    }
    
    // Checks if a single track matches search criteria, and returns information about the match, if there is one
    private func trackMatchesQuery(_ track: Track, _ searchQuery: SearchQuery) -> (matched: Bool, matchedField: String?, matchedFieldValue: String?) {
        
        // Compare name field if included in search
        if (searchQuery.fields.name) {
            
            // Check both the filename and the display name
            
            let filename = track.fileSystemInfo.fileName
            if compare(filename, searchQuery) {
                return (true, "filename", filename)
            }
            
            let displayName = track.conciseDisplayName
            if compare(displayName, searchQuery) {
                return (true, "name", displayName)
            }
        }
        
        // Compare title field if included in search
        if searchQuery.fields.title, let title = track.displayInfo.title, compare(title, searchQuery) {
            return (true, "title", title)
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
        return tracks.addItem(track)
    }
    
    func clear() {
        tracks.removeAll()
    }
    
    private func optionalIndexedOperation(_ index: Int, _ successValueFunction: () -> Track) -> Track? {
        return index < 0 || index >= tracks.count ? nil : successValueFunction()
    }
 
    private func removeTrackAtIndex(_ index: Int) -> Track? {
        return optionalIndexedOperation(index, {tracks.remove(at: index)})
    }
    
    private func removeTrack(_ track: Track) -> Int? {
        return tracks.removeItem(track)
    }
    
    func removeTracks(_ removedTracks: [Track]) -> IndexSet {
        return tracks.removeItems(removedTracks)
    }
    
    func removeTracks(_ indices: IndexSet) -> [Track] {
        return tracks.removeItems(indices)
    }
    
    // Assume tracks can be moved
    func moveTracksToTop(_ indices: IndexSet) -> ItemMoveResults {
        
        // 1 - Move tracks to top
        // 2 - Sort the [srcIndex: destIndex] results in ascending order by srcIndex
        // 3 - Map the results to an array of TrackMoveResult
        let results: [TrackMoveResult] = tracks.moveItemsToTop(indices).sorted(by: {$0.0 < $1.0}).map {TrackMoveResult($0.key, $0.value)}
        
        return ItemMoveResults(results, .tracks)
    }
    
    func moveTracksToBottom(_ indices: IndexSet) -> ItemMoveResults {
        
        // 1 - Move tracks to bottom
        // 2 - Sort the [srcIndex: destIndex] results in descending order by srcIndex
        // 3 - Map the results to an array of TrackMoveResult
        let results: [TrackMoveResult] = tracks.moveItemsToBottom(indices).sorted(by: {$0.0 > $1.0}).map {TrackMoveResult($0.key, $0.value)}
        
        return ItemMoveResults(results, .tracks)
    }
    
    func moveTracksUp(_ indices: IndexSet) -> ItemMoveResults {
        
        // 1 - Move tracks up
        // 2 - Sort the [srcIndex: destIndex] results in ascending order by srcIndex
        // 3 - Map the results to an array of TrackMoveResult
        let results: [TrackMoveResult] = tracks.moveItemsUp(indices).sorted(by: {$0.0 < $1.0}).map {TrackMoveResult($0.key, $0.value)}
        
        return ItemMoveResults(results, .tracks)
    }
    
    func moveTracksDown(_ indices: IndexSet) -> ItemMoveResults {
        
        // 1 - Move tracks down
        // 2 - Sort the [srcIndex: destIndex] results in descending order by srcIndex
        // 3 - Map the results to an array of TrackMoveResult
        let results: [TrackMoveResult] = tracks.moveItemsDown(indices).sorted(by: {$0.0 > $1.0}).map {TrackMoveResult($0.key, $0.value)}
        
        return ItemMoveResults(results, .tracks)
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
