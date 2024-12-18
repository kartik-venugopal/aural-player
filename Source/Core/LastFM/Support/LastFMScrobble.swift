//
// LastFMScrobble.swift
// Aural
// 
// Copyright © 2024 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

class LastFMScrobble {
    
    let artist: String
    let title: String
    let timestamp: Int
    
    let album: String?
    var numScrobbleAttempts: Int
    
    private static let numberOfSecondsInTwoWeeks: Int = 14 * 86400
    private static let maxScrobbleAttempts: Int = 5
    
    var hasExpired: Bool {
        (Date.nowEpochTime - timestamp) >= Self.numberOfSecondsInTwoWeeks
    }
    
    var reachedMaxAttempts: Bool {
        numScrobbleAttempts >= Self.maxScrobbleAttempts
    }
    
    var isCurrent: Bool {
        !(hasExpired || reachedMaxAttempts)
    }
    
    lazy var id: String = "\(artist)|\(title)|\(album ?? "")"
    
    init(artist: String, title: String, timestamp: Int, album: String?) {
        
        self.artist = artist
        self.title = title
        self.timestamp = timestamp
        self.album = album
        self.numScrobbleAttempts = 1
    }
    
    init?(persistentState: LastFMScrobblePersistentState) {
        
        guard let artist = persistentState.artist, let title = persistentState.title,
              let timestamp = persistentState.timestamp, let numScrobbleAttempts = persistentState.numScrobbleAttempts else {
            
            return nil
        }
        
        self.artist = artist
        self.title = title
        self.timestamp = timestamp
        
        self.album = persistentState.album
        self.numScrobbleAttempts = numScrobbleAttempts
    }
    
    func markFailedAttempt() {
        numScrobbleAttempts.increment()
    }
}

struct LastFMScrobblePersistentState: Codable {
    
    let artist: String?
    let title: String?
    let timestamp: Int?
    
    let album: String?
    var numScrobbleAttempts: Int?
    
    init(scrobble: LastFMScrobble) {
        
        self.artist = scrobble.artist
        self.title = scrobble.title
        self.timestamp = scrobble.timestamp
        self.album = scrobble.album
        self.numScrobbleAttempts = scrobble.numScrobbleAttempts
    }
}
