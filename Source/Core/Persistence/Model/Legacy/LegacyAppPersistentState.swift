//
//  LegacyAppPersistentState.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

///
/// Top-level persistent state object that encapsulates all application state.
///
struct LegacyAppPersistentState: Codable {
    
    var appVersion: String?
    
    var ui: LegacyUIPersistentState?
    
    var playlist: LegacyPlaylistPersistentState?
    var audioGraph: LegacyAudioGraphPersistentState?
    
    var playbackSequence: LegacyPlaybackSequencePersistentState?
    var playbackProfiles: [LegacyPlaybackProfilePersistentState]?
    
    var history: LegacyHistoryPersistentState?
    var favorites: [LegacyFavoritePersistentState]?
    var bookmarks: [LegacyBookmarkPersistentState]?
    
    var musicBrainzCache: LegacyMusicBrainzCachePersistentState?
//    var lastFMCache: LastFMScrobbleCachePersistentState?
    
    init() {}
}

typealias URLPath = String
typealias DateString = String

struct LegacyPlaylistPersistentState: Codable {
    
    // List of track files (as URL paths).
    let tracks: [URLPath]?
}

struct LegacyPlaybackSequencePersistentState: Codable {
    
    let repeatMode: RepeatMode?
    let shuffleMode: ShuffleMode?
}

struct LegacyFavoritePersistentState: Codable {

    let file: URLPath?   // URL path
}

struct LegacyBookmarkPersistentState: Codable {
    
    let name: String?
    let file: URLPath?   // URL path
    let startPosition: Double?
    let endPosition: Double?
}

struct LegacyPlaybackProfilePersistentState: Codable {
    
    let file: URLPath?
    let lastPosition: Double?
}

struct LegacyMusicBrainzCachePersistentState: Codable {

    let releases: [LegacyMusicBrainzCacheEntryPersistentState]?
    let recordings: [LegacyMusicBrainzCacheEntryPersistentState]?
}

struct LegacyMusicBrainzCacheEntryPersistentState: Codable {
    
    let artist: String?
    let title: String?
    let file: URLPath?
}
