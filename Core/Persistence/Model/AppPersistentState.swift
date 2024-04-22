//
//  AppPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Top-level persistent state object that encapsulates all application state.
///
struct AppPersistentState: Codable {
    
    var appVersion: String?
    
    #if os(macOS)
    var ui: UIPersistentState?
    #endif
    
    var playQueue: PlayQueuePersistentState?
    var audioGraph: AudioGraphPersistentState?
//    var library: LibraryPersistentState?
    
    var playlists: PlaylistsPersistentState?
    var favorites: FavoritesPersistentState?
    var bookmarks: BookmarksPersistentState?
    
    var playbackProfiles: [PlaybackProfilePersistentState]?
    
    var musicBrainzCache: MusicBrainzCachePersistentState?
    var lastFMCache: LastFMScrobbleCachePersistentState?
    
    init() {}
    
    init(legacyAppPersistentState: LegacyAppPersistentState) {
        
        self.playQueue = .init(legacyPlaylistPersistentState: legacyAppPersistentState.playlist,
                               legacyPlaybackSequencePersistentState: legacyAppPersistentState.playbackSequence,
                               legacyHistoryPersistentState: legacyAppPersistentState.history)
        
        self.audioGraph = AudioGraphPersistentState(legacyPersistentState: legacyAppPersistentState.audioGraph)
        
        self.favorites = .init(legacyPersistentState: legacyAppPersistentState.favorites)
        
        self.bookmarks = .init(legacyPersistentState: legacyAppPersistentState.bookmarks)
        
        
        self.playbackProfiles = legacyAppPersistentState.playbackProfiles?.compactMap {PlaybackProfilePersistentState(legacyPersistentState: $0)}
        
        self.ui = UIPersistentState(legacyPersistentState: legacyAppPersistentState.ui)
        
        self.musicBrainzCache = MusicBrainzCachePersistentState(legacyPersistentState: legacyAppPersistentState.musicBrainzCache)
    }
    
    static let defaults: AppPersistentState = AppPersistentState()
}
