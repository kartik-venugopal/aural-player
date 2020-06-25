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
        return tracks.itemAtIndex(index)
    }
    
    func indexOfTrack(_ track: Track) -> Int?  {
        return tracks.firstIndex(of: track)
    }
    
    func search(_ searchQuery: SearchQuery) -> SearchResults {
        
        return SearchResults(tracks.compactMap {executeQuery($0, searchQuery)}.map {
            
            SearchResult(location: SearchResultLocation(trackIndex: -1, track: $0.track, groupInfo: nil),
                         match: ($0.matchedField, $0.matchedFieldValue))
        })
    }
    
    private func executeQuery(_ track: Track, _ query: SearchQuery) -> SearchQueryMatch? {
        
        if query.fields.name {
            
            // Check both the filename and the display name
            
            let filename = track.fileSystemInfo.fileName
            if query.compare(filename) {
                return SearchQueryMatch(track: track, matchedField: "filename", matchedFieldValue: filename)
            }
            
            let displayName = track.conciseDisplayName
            if query.compare(displayName) {
                return SearchQueryMatch(track: track, matchedField: "name", matchedFieldValue: displayName)
            }
        }
        
        // Compare title field if included in search
        if query.fields.title, let title = track.displayInfo.title, query.compare(title) {
            return SearchQueryMatch(track: track, matchedField: "title", matchedFieldValue: title)
        }
        
        // Didn't match
        return nil
    }
    
    // MARK: Mutator functions
    
    func addTrack(_ track: Track) -> Int {
        return tracks.addItem(track)
    }
    
    func clear() {
        tracks.removeAll()
    }
 
    private func removeTrackAtIndex(_ index: Int) -> Track? {
        return tracks.removeItem(index)
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
        let results: [TrackMoveResult] = tracks.moveItemsToTop(indices).sorted(by: {$0.key < $1.key}).map {TrackMoveResult($0.key, $0.value)}
        
        return ItemMoveResults(results, .tracks)
    }
    
    func moveTracksToBottom(_ indices: IndexSet) -> ItemMoveResults {
        
        // 1 - Move tracks to bottom
        // 2 - Sort the [srcIndex: destIndex] results in descending order by srcIndex
        // 3 - Map the results to an array of TrackMoveResult
        let results: [TrackMoveResult] = tracks.moveItemsToBottom(indices).sorted(by: {$0.key > $1.key}).map {TrackMoveResult($0.key, $0.value)}
        
        return ItemMoveResults(results, .tracks)
    }
    
    func moveTracksUp(_ indices: IndexSet) -> ItemMoveResults {
        
        // 1 - Move tracks up
        // 2 - Sort the [srcIndex: destIndex] results in ascending order by srcIndex
        // 3 - Map the results to an array of TrackMoveResult
        let results: [TrackMoveResult] = tracks.moveItemsUp(indices).sorted(by: {$0.key < $1.key}).map {TrackMoveResult($0.key, $0.value)}
        
        return ItemMoveResults(results, .tracks)
    }
    
    func moveTracksDown(_ indices: IndexSet) -> ItemMoveResults {
        
        // 1 - Move tracks down
        // 2 - Sort the [srcIndex: destIndex] results in descending order by srcIndex
        // 3 - Map the results to an array of TrackMoveResult
        let results: [TrackMoveResult] = tracks.moveItemsDown(indices).sorted(by: {$0.key > $1.key}).map {TrackMoveResult($0.key, $0.value)}
        
        return ItemMoveResults(results, .tracks)
    }
 
    func sort(_ sort: Sort) {
        
        if sort.tracksSort != nil {
            tracks.sort(by: SortComparator(sort, self.displayNameForTrack).compareTracks)
        }
    }
    
    func dropTracks(_ sourceIndexes: IndexSet, _ dropIndex: Int) -> IndexSet {
        return IndexSet(tracks.dragAndDropItems(sourceIndexes, dropIndex).values)
    }
}
