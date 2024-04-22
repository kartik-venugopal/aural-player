//
//  BookmarksPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

struct BookmarksPersistentState: Codable {
    
    let bookmarks: [BookmarkPersistentState]?
    
    init(bookmarks: [BookmarkPersistentState]) {
        self.bookmarks = bookmarks
    }
    
    init(legacyPersistentState: [LegacyBookmarkPersistentState]?) {
        self.bookmarks = legacyPersistentState?.map {BookmarkPersistentState(legacyPersistentState: $0)}
    }
}

///
/// Persistent state for a single bookmark.
///
/// - SeeAlso: `Bookmark`
///
struct BookmarkPersistentState: Codable {
    
    let name: String?
    let trackFile: URL?   // URL path
    let startPosition: Double?
    let endPosition: Double?
    
    init(bookmark: Bookmark) {
        
        self.name = bookmark.name
        self.trackFile = bookmark.track.file
        self.startPosition = bookmark.startPosition
        self.endPosition = bookmark.endPosition
    }
    
    init(legacyPersistentState: LegacyBookmarkPersistentState) {
        
        self.name = legacyPersistentState.name
        
        self.trackFile = {
           
            guard let path = legacyPersistentState.file else {return nil}
            return URL(fileURLWithPath: path)
        }()
        
        self.startPosition = legacyPersistentState.startPosition
        self.endPosition = legacyPersistentState.endPosition
    }
}
