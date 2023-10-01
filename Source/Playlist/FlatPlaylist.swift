//
//  FlatPlaylist.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// The flat (non-hierarchical) playlist which arranges tracks in a linear, sequential, or "flat" structure.
///
/// Each track is a top-level item and can be located with an index, analogous to accessing elements
/// in a one-dimensional array.
///
/// This is the backing playlist for the *Tracks* playlist view.
///
class FlatPlaylist: FlatPlaylistProtocol {
 
    var tracks: [Track] = [Track]()
    
    // MARK: Accessor functions
    
    var size: Int {tracks.count}
    
    var duration: Double {
        tracks.reduce(0.0, {(totalSoFar: Double, track: Track) -> Double in totalSoFar + track.duration})
    }
    
    func displayNameForTrack(_ track: Track) -> String {
        return track.displayName
    }
    
    func trackAtIndex(_ index: Int) -> Track? {
        return tracks.itemAtIndex(index)
    }
    
    func indexOfTrack(_ track: Track) -> Int?  {
        return tracks.firstIndex(of: track)
    }
    
    func search(_ searchQuery: SearchQuery) -> SearchResults {
        return SearchResults(tracks.enumerated().compactMap {executeQuery(index: $0, track: $1, searchQuery)})
    }
    
    private func executeQuery(index: Int, track: Track, _ query: SearchQuery) -> SearchResult? {

        // Check both the filename and the display name
        if query.fields.contains(.name) {
            
            let displayName = track.displayName
            if query.compare(displayName) {
                
                return SearchResult(location: SearchResultLocation(track: track, trackIndex: index, groupInfo: nil),
                                    match: SearchResultMatch(fieldKey: "name", fieldValue: displayName))
            }
            
            let filename = track.fileSystemInfo.fileName
            if query.compare(filename) {

                return SearchResult(location: SearchResultLocation(track: track, trackIndex: index, groupInfo: nil),
                                    match: SearchResultMatch(fieldKey: "filename", fieldValue: filename))
            }
        }
        
        // Compare title field if included in search
        if query.fields.contains(.title), let title = track.title, query.compare(title) {

            return SearchResult(location: SearchResultLocation(track: track, trackIndex: index, groupInfo: nil),
                                match: SearchResultMatch(fieldKey: "title", fieldValue: title))
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
 
    func removeTracks(_ removedTracks: [Track]) -> IndexSet {
        return tracks.removeItems(removedTracks)
    }
    
    func removeTracks(_ indices: IndexSet) -> [Track] {
        return tracks.removeItems(indices)
    }
    
    func moveTracksToTop(_ indices: IndexSet) -> ItemMoveResults {
        
        return ItemMoveResults(results: tracks.moveItemsToTop(indices).map {TrackMoveResult($0.key, $0.value)}, playlistType: .tracks)
    }
    
    func moveTracksToBottom(_ indices: IndexSet) -> ItemMoveResults {
        
        return ItemMoveResults(results: tracks.moveItemsToBottom(indices).map {TrackMoveResult($0.key, $0.value)}, playlistType: .tracks)
    }
    
    func moveTracksUp(_ indices: IndexSet) -> ItemMoveResults {
        
        return ItemMoveResults(results: tracks.moveItemsUp(indices).map {TrackMoveResult($0.key, $0.value)}, playlistType: .tracks)
    }
    
    func moveTracksDown(_ indices: IndexSet) -> ItemMoveResults {
        
        return ItemMoveResults(results: tracks.moveItemsDown(indices).map {TrackMoveResult($0.key, $0.value)}, playlistType: .tracks)
    }
    
    func sort(_ sort: Sort) {
        tracks.sort(by: SortComparator(sort, self.displayNameForTrack).compareTracks)
    }
    
    func dropTracks(_ sourceIndexes: IndexSet, _ dropIndex: Int) -> ItemMoveResults {
        
        return ItemMoveResults(results: tracks.dragAndDropItems(sourceIndexes, dropIndex).map {TrackMoveResult($0.key, $0.value)}, playlistType: .tracks)
    }
}
