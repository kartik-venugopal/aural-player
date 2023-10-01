//
//  AppPersistentState.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// Top-level persistent state object that encapsulates all application state.
///
struct AppPersistentState: Codable {
    
    var appVersion: String?
    
    var ui: UIPersistentState?
    
    var playlist: PlaylistPersistentState?
    var audioGraph: AudioGraphPersistentState?
    
    var playbackSequence: PlaybackSequencePersistentState?
    var playbackProfiles: [PlaybackProfilePersistentState]?
    
    var history: HistoryPersistentState?
    var favorites: [FavoritePersistentState]?
    var bookmarks: [BookmarkPersistentState]?
    
    var musicBrainzCache: MusicBrainzCachePersistentState?
    
    init() {}
    
    static let defaults: AppPersistentState = AppPersistentState()
}
