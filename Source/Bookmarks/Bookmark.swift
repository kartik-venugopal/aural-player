//
//  Bookmark.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// Encapsulates a user-defined bookmark (i.e. a remembered playback position(s) within a track).
///
class Bookmark: UserManagedObject, Hashable {
    
    // A name or description (e.g. "2nd chapter of audiobook")
    private var _name: String
    
    // Used by the UI (track.displayName)
    var name: String {
        
        get {track?.displayName ?? _name}
        set {_name = newValue}
    }
    
    var key: String {
        
        get {name}
        set {name = newValue}
    }
    
    var userDefined: Bool {true}
    
    // The file of the track being bookmarked
    let file: URL
    
    var track: Track?
    
    // Seek position within track, expressed in seconds
    let startPosition: Double
    
    // Seek position within track, expressed in seconds
    let endPosition: Double?
    
    convenience init(_ name: String, _ file: URL, _ startPosition: Double) {
        self.init(name, file, startPosition, nil)
    }
    
    init(_ name: String, _ file: URL, _ startPosition: Double, _ endPosition: Double?) {
        
        self._name = name
        self.file = file
        self.startPosition = startPosition
        self.endPosition = endPosition
    }
    
    init(_ name: String, _ track: Track, _ startPosition: Double, _ endPosition: Double?) {
        
        self._name = name
        self.track = track
        self.file = track.file
        self.startPosition = startPosition
        self.endPosition = endPosition
    }
    
    init?(persistentState: BookmarkPersistentState) {
        
        guard let path = persistentState.file,
              let startPosition = persistentState.startPosition else {return nil}
        
        let file = URL(fileURLWithPath: path)
        self.file = file
        self._name = persistentState.name ?? file.lastPathComponent
        
        self.startPosition = startPosition
        self.endPosition = persistentState.endPosition
    }
    
    static func == (lhs: Bookmark, rhs: Bookmark) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
