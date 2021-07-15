//
//  BookmarkPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for a single bookmark.
///
/// - SeeAlso: `Bookmark`
///
struct BookmarkPersistentState: Codable {
    
    let name: String?
    let file: URLPath?   // URL path
    let startPosition: Double?
    let endPosition: Double?
    
    init(bookmark: Bookmark) {
        
        self.name = bookmark.name
        self.file = bookmark.file.path
        self.startPosition = bookmark.startPosition
        self.endPosition = bookmark.endPosition
    }
}
