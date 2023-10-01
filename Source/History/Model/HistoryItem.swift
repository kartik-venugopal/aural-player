//
//  HistoryItem.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// An abstract base class for all history items.
///
class HistoryItem: Equatable {
    
    // The filesystem location of the item
    var file: URL
    
    // A timestamp used in comparisons with other items, to maintain chronological order
    var time: Date
    
    // Display information used in menu items
    private var _displayName: String
    
    var track: Track?
    
    var displayName: String {
        
        get {track?.displayName ?? _displayName}
        set {_displayName = newValue}
    }
    
    // Used for tracks
    init(_ file: URL, _ displayName: String, _ time: Date) {
        
        self.file = file
        self.time = time
        
        // Default the displayName to file name (intended to be replaced later)
        self._displayName = displayName
    }
    
    static func == (lhs: HistoryItem, rhs: HistoryItem) -> Bool {
        lhs.file == rhs.file
    }
}
