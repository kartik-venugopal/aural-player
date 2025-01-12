//
//  MusicBrainzCachePersistentState.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for the MusicBrainz in-memory / on-disk cache.
///
/// - SeeAlso: `MusicBrainzCache`
///
struct MusicBrainzCachePersistentState: Codable {

    let releases: [MusicBrainzCacheEntryPersistentState]?
    let recordings: [MusicBrainzCacheEntryPersistentState]?
    
    init(releases: [MusicBrainzCacheEntryPersistentState]?, recordings: [MusicBrainzCacheEntryPersistentState]?) {
        
        self.releases = releases
        self.recordings = recordings
    }
    
    init(legacyPersistentState: LegacyMusicBrainzCachePersistentState?) {
        
        self.releases = legacyPersistentState?.releases?.compactMap {MusicBrainzCacheEntryPersistentState(legacyPersistentState: $0)}
        self.recordings = legacyPersistentState?.recordings?.compactMap {MusicBrainzCacheEntryPersistentState(legacyPersistentState: $0)}
    }
}

///
/// Persistent state for a single entry within the MusicBrainz in-memory / on-disk cache.
///
/// - SeeAlso: `MusicBrainzCache`
///
struct MusicBrainzCacheEntryPersistentState: Codable {
    
    let artist: String?
    let title: String?
    let file: URL?
    
    init(artist: String?, title: String?, file: URL?) {
        
        self.artist = artist
        self.title = title
        self.file = file
    }
    
    init?(legacyPersistentState: LegacyMusicBrainzCacheEntryPersistentState) {
        
        guard let artist = legacyPersistentState.artist,
              let title = legacyPersistentState.title,
              let file = legacyPersistentState.file else {
            
            return nil
        }
        
        self.file = URL(fileURLWithPath: file)
        self.artist = artist
        self.title = title
    }
}
