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

struct PlaybackProfilePersistentState: Codable {
    
    let file: URLPath?
    let lastPosition: Double?
    
    init(profile: PlaybackProfile) {
        
        self.file = profile.file.path
        self.lastPosition = profile.lastPosition
    }
}
