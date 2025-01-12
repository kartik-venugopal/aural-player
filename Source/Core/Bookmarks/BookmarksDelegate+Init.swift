//
//  BookmarksDelegate+Init.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

extension BookmarksDelegate {
    
    func initialize(fromPersistentState persistentState: BookmarksPersistentState?) {
        
        guard let state = persistentState else {return}
        var tracksByFile: [URL: Track] = [:]
        
        DispatchQueue.global(qos: .utility).async {
            
            for bookmark in state.bookmarks ?? [] {
                
                guard let bookmarkName = bookmark.name, let trackFile = bookmark.trackFile, let startPosition = bookmark.startPosition else {continue}
                
                let track = tracksByFile[trackFile] ?? Track(trackFile)
                self.bookmarks.addObject(Bookmark(name: bookmarkName, track: track, startPosition: startPosition, endPosition: bookmark.endPosition))
                
                guard tracksByFile[trackFile] == nil else {continue}
                
                tracksByFile[trackFile] = track
                
                trackReader.loadMetadataAsync(for: track, onQueue: TrackReader.mediumPriorityQueue)
            }
        }
    }
}
