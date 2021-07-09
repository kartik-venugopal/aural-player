//
//  FlatPlaylist.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

/*
    The flat playlist is a non-hierarchical playlist, in which tracks are arranged in a linear fashion, and in which each track is a top-level item and can be located with just an index.
 */
class FlatPlaylist: FlatPlaylistCRUDProtocol {
 
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
            
            let filename = track.fileSystemInfo.fileName
            if query.compare(filename) {

                return SearchResult(location: SearchResultLocation(trackIndex: index, track: track, groupInfo: nil),
                                    match: ("filename", filename))
            }
            
            let displayName = track.displayName
            if query.compare(displayName) {
                
                return SearchResult(location: SearchResultLocation(trackIndex: index, track: track, groupInfo: nil),
                                    match: ("name", displayName))
            }
        }
        
        // Compare title field if included in search
        if query.fields.contains(.title), let title = track.title, query.compare(title) {

            return SearchResult(location: SearchResultLocation(trackIndex: index, track: track, groupInfo: nil),
                                match: ("title", title))
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
        return ItemMoveResults(tracks.moveItemsToTop(indices).map {TrackMoveResult($0.key, $0.value)}, .tracks)
    }
    
    func moveTracksToBottom(_ indices: IndexSet) -> ItemMoveResults {
        return ItemMoveResults(tracks.moveItemsToBottom(indices).map {TrackMoveResult($0.key, $0.value)}, .tracks)
    }
    
    func moveTracksUp(_ indices: IndexSet) -> ItemMoveResults {
        return ItemMoveResults(tracks.moveItemsUp(indices).map {TrackMoveResult($0.key, $0.value)}, .tracks)
    }
    
    func moveTracksDown(_ indices: IndexSet) -> ItemMoveResults {
        return ItemMoveResults(tracks.moveItemsDown(indices).map {TrackMoveResult($0.key, $0.value)}, .tracks)
    }
 
    func sort(_ sort: Sort) {
        tracks.sort(by: SortComparator(sort, self.displayNameForTrack).compareTracks)
    }
    
    func dropTracks(_ sourceIndexes: IndexSet, _ dropIndex: Int) -> ItemMoveResults {
        return ItemMoveResults(tracks.dragAndDropItems(sourceIndexes, dropIndex).map {TrackMoveResult($0.key, $0.value)}, .tracks)
    }
}
