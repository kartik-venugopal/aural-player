//
//  Bookmark.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates a user-defined bookmark (i.e. a remembered playback position(s) within a track).
///
class Bookmark: UserManagedObject, Hashable {
    
    // A name or description (e.g. "2nd chapter of audiobook")
    var name: String
    
    // Used by the UI (track.displayName)
    var key: String {
        
        get {name}
        set {name = newValue}
    }
    
    var userDefined: Bool {true}
    
    // The file of the track being bookmarked
    let track: Track
    
    // Seek position within track, expressed in seconds
    let startPosition: Double
    
    // Seek position within track, expressed in seconds
    let endPosition: Double?
    
    init(name: String, track: Track, startPosition: Double, endPosition: Double?) {
        
        self.name = name
        self.track = track
        self.startPosition = startPosition
        self.endPosition = endPosition
    }
    
//    init?(persistentState: BookmarkPersistentState) {
//        
//        guard let file = persistentState.file,
//              let startPosition = persistentState.startPosition else {return nil}
//        
//        self.name = persistentState.name ?? file.lastPathComponent
//        
//        self.startPosition = startPosition
//        self.endPosition = persistentState.endPosition
//    }
    
    static func == (lhs: Bookmark, rhs: Bookmark) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
