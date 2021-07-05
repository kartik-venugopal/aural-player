//
//  PersistentAppState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Encapsulates all application state. It is persisted to disk upon exit and loaded into the application upon startup.
 */
struct PersistentAppState: Codable {
    
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
    
    static let defaults: PersistentAppState = PersistentAppState()
}
