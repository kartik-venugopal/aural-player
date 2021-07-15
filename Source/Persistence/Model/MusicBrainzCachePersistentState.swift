//
//  MusicBrainzCachePersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
}

///
/// Persistent state for a single entry within the MusicBrainz in-memory / on-disk cache.
///
/// - SeeAlso: `MusicBrainzCache`
///
struct MusicBrainzCacheEntryPersistentState: Codable {
    
    let artist: String?
    let title: String?
    let file: URLPath?
}
