/*
    Encapsulates all CRUD logic for a playlist
 */
import Foundation
import AVFoundation

class Playlist: PlaylistCRUDProtocol {
    
    private var tracks: [Track] = [Track]()
    
    // A map to quickly look up tracks by (absolute) file path (used when adding tracks, to avoid duplicates)
    private var tracksByFilePath: [String: Track] = [String: Track]()
    
    func getTracks() -> [Track] {
        return tracks
    }
    
    func peekTrackAt(_ index: Int?) -> IndexedTrack? {
        let invalidIndex: Bool = index == nil || index! < 0 || index! >= tracks.count
        return invalidIndex ? nil : IndexedTrack(tracks[index!], index!)
    }
    
    func size() -> Int {
        return tracks.count
    }
    
    func totalDuration() -> Double {
        
        var totalDuration: Double = 0
        
        for track in tracks {
            totalDuration += track.duration
        }
        
        return totalDuration
    }
    
    func summary() -> (size: Int, totalDuration: Double) {
        return (tracks.count, totalDuration())
    }
    
    func addTrack(_ track: Track) -> Int {
        
        if (!trackExists(track)) {
            doAddTrack(track)
            return tracks.count - 1
        }
        
        // This means nothing was added
        return -1
    }
    
    private func doAddTrack(_ track: Track) {
        tracks.append(track)
        tracksByFilePath[track.file.path] = track
    }
    
    // Checks whether or not a track with the given absolute file path already exists.
    private func trackExists(_ track: Track) -> Bool {
        return tracksByFilePath[track.file.path] != nil
    }
    
    private func removeTrack(_ index: Int) {
        
        let track: Track = tracks[index]
        
        tracksByFilePath.removeValue(forKey: track.file.path)
        tracks.remove(at: index)
    }
    
    func removeTracks(_ indexes: [Int]) {
        
        // Need to remove tracks in descending order of index, so that indexes of yet-to-be-removed elements are not messed up
        
        // Sort descending
        let sortedIndexes = indexes.sorted(by: {x, y -> Bool in x > y})
        
        // TODO: Will forEach always iterate array in order ??? If not, cannot use it. Array needs to be iterated in exact order.
        sortedIndexes.forEach({removeTrack($0)})
    }
    
    func indexOfTrack(_ track: Track?) -> Int?  {
        
        if (track == nil) {
            return nil
        }
        
        return tracks.index(where: {$0 == track})
    }
    
    func clear() {
        tracks.removeAll()
        tracksByFilePath.removeAll()
    }
    
    func save(_ file: URL) {
        PlaylistIO.savePlaylist(file)
    }
    
    func moveTrackUp(_ index: Int) -> Int {
        
        if (index <= 0) {
            return index
        }
        
        let upIndex = index - 1
        swapTracks(index, upIndex)
        return upIndex
    }
    
    func moveTrackDown(_ index: Int) -> Int {
        
        if (index >= (tracks.count - 1)) {
            return index
        }
        
        let downIndex = index + 1
        swapTracks(index, downIndex)
        return downIndex
    }
    
    // Swaps two tracks in the array of tracks
    private func swapTracks(_ trackIndex1: Int, _ trackIndex2: Int) {
        swap(&tracks[trackIndex1], &tracks[trackIndex2])
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
    
    // Returns all state for this playlist that needs to be persisted to disk
    func persistentState() -> PlaylistState {
        
        let state = PlaylistState()
        
        for track in tracks {
            state.tracks.append(track.file)
        }
        
        return state
    }
}
