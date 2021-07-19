//
//  Favorite.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// Encapsulates a user-defined favorite (a track marked as such).
///
class Favorite: MappedPreset, Hashable {
    
    // The file of the track being favorited
    let file: URL
    
    private var _name: String
    
    // Used by the UI (track.displayName)
    var name: String {
        
        get {track?.displayName ?? _name}
        set {_name = newValue}
    }
    
    var key: String {
        
        get {file.path}
        set {} // Do nothing
    }
    
    var userDefined: Bool {true}
    
    var track: Track?
    
    init(_ track: Track) {
        
        self.track = track
        self.file = track.file
        self._name = track.displayName
    }
    
    init(_ file: URL, _ name: String) {
        
        self.file = file
        self._name = name
    }
    
    init?(persistentState: FavoritePersistentState) {
        
        guard let path = persistentState.file, let name = persistentState.name else {return nil}
        
        self.file = URL(fileURLWithPath: path)
        self._name = name
    }
    
    static func == (lhs: Favorite, rhs: Favorite) -> Bool {
        lhs.file == rhs.file
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(file)
    }
}
