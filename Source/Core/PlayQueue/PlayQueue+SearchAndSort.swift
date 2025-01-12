//
//  PlayQueue+SearchAndSort.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

extension PlayQueue {
    
    func executeQuery(index: Int, track: Track, _ query: SearchQuery) -> SearchResult? {

        // Check both the filename and the display name
        if query.fields.contains(.name) {
            
            let displayName = track.displayName
            if query.compare(displayName) {
                
                return SearchResult(location: PlayQueueSearchResultLocation(scope: .playQueue, track: track, index: index),
                                    match: SearchResultMatch(fieldKey: "Name", fieldValue: displayName))
            }
            
            let filename = track.fileSystemInfo.fileName
            if query.compare(filename) {

                return SearchResult(location: PlayQueueSearchResultLocation(scope: .playQueue, track: track, index: index),
                                    match: SearchResultMatch(fieldKey: "Filename", fieldValue: filename))
            }
        }
        
        // Compare title field if included in search
        if query.fields.contains(.title), let title = track.title, query.compare(title) {

            return SearchResult(location: PlayQueueSearchResultLocation(scope: .playQueue, track: track, index: index),
                                match: SearchResultMatch(fieldKey: "Title", fieldValue: title))
        }
        
        // Compare artist field if included in search
        if query.fields.contains(.artist), let artist = track.artist, query.compare(artist) {

            return SearchResult(location: PlayQueueSearchResultLocation(scope: .playQueue, track: track, index: index),
                                match: SearchResultMatch(fieldKey: "Artist", fieldValue: artist))
        }
        
        // Compare album field if included in search
        if query.fields.contains(.album), let album = track.album, query.compare(album) {

            return SearchResult(location: PlayQueueSearchResultLocation(scope: .playQueue, track: track, index: index),
                                match: SearchResultMatch(fieldKey: "Album", fieldValue: album))
        }
        
        // Didn't match
        return nil
    }

//    func sort(_ sort: Sort) -> SortResults {
//
////        tracks.sort(by: SortComparator(sort, {track in track.defaultDisplayName}).compareTracks)
//        return SortResults(.tracks, sort)
//    }
//
//    func sort(by comparator: (Track, Track) -> Bool) {
////        tracks.sort(by: comparator)
//    }
}
