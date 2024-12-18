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

struct LastFMScrobbleCachePersistentState: Codable {
    
    let scrobbles: [LastFMScrobblePersistentState]?
}
