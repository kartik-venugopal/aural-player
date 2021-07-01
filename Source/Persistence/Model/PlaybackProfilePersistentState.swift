//
//  PlaybackProfilePersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class PlaybackProfilePersistentState: PersistentStateProtocol {
    
    let file: URL
    var lastPosition: Double
    
    init(file: URL, lastPosition: Double) {
        
        self.file = file
        self.lastPosition = lastPosition
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let file = map.urlValue(forKey: "file"),
              let lastPosition = map.doubleValue(forKey: "lastPosition") else {return nil}
        
        self.file = file
        self.lastPosition = lastPosition
    }
}
