//
//  LastFMScrobbleCache.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import OrderedCollections

fileprivate let numberOfSecondsInTwoWeeks: Int = 14 * 86400
fileprivate let maxScrobbleAttempts: Int = 5

class LastFMScrobbleCache: PersistentModelObject {
    
    private var queue: OrderedDictionary<String, LastFMScrobble> = .init()
    
    var allEntries: [LastFMScrobble] {
        Array(queue.values)
    }
    
    init(persistentState: LastFMScrobbleCachePersistentState?) {
        
        let scrobbles = persistentState?.scrobbles?.compactMap {LastFMScrobble(persistentState: $0)}.filter {$0.isCurrent} ?? []
        
        for scrobble in scrobbles {
            queue[scrobble.id] = scrobble
        }
    }
    
    func markFailedScrobbleAttempt(artist: String, title: String, album: String?, timestamp: Int) {
        
        let attemptId = "\(artist)|\(title)|\(album ?? "")"
        
        if let existingScrobble = queue[attemptId] {
            
            existingScrobble.markFailedAttempt()
            
            if existingScrobble.reachedMaxAttempts {
                queue.removeValue(forKey: attemptId)
            }
            
        } else {
            
            let newScrobble = LastFMScrobble(artist: artist, title: title, timestamp: timestamp, album: album)
            queue[attemptId] = newScrobble
        }
    }
    
    func invalidateEntry(artist: String, title: String, album: String?) {
        
        let attemptId = "\(artist)|\(title)|\(album ?? "")"
        queue.removeValue(forKey: attemptId)
    }
    
    var persistentState: LastFMScrobbleCachePersistentState {
        LastFMScrobbleCachePersistentState(scrobbles: queue.values.map {LastFMScrobblePersistentState(scrobble: $0)})
    }
}

class LastFMScrobble {
    
    let artist: String
    let title: String
    let timestamp: Int
    
    let album: String?
    var numScrobbleAttempts: Int
    
    var hasExpired: Bool {
        (Date.nowEpochTime - timestamp) >= numberOfSecondsInTwoWeeks
    }
    
    var reachedMaxAttempts: Bool {
        numScrobbleAttempts >= maxScrobbleAttempts
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

struct LastFMScrobbleCachePersistentState: Codable {
    
    let scrobbles: [LastFMScrobblePersistentState]?
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
