//
//  LegacyPlaylistPreferences.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class LegacyPlaylistPreferences {
    
    var playlistOnStartup: LegacyPlaylistStartupOptions?
    
    // This will be used only when playlistOnStartup == PlaylistStartupOptions.loadFile
    var playlistFile: URL?
    
    // This will be used only when playlistOnStartup == PlaylistStartupOptions.loadFolder
    var tracksFolder: URL?
    
    var showNewTrackInPlaylist: Bool?
    var showChaptersList: Bool?
    
    var dragDropAddMode: LegacyPlaylistTracksAddMode?
    var openWithAddMode: LegacyPlaylistTracksAddMode?
    
    // ------ MARK: Property keys ---------
    
    private static let keyPrefix: String = "playlist"
    
    private static let key_playlistOnStartup: String = "\(keyPrefix).playlistOnStartup"
    private static let key_playlistFile: String = "\(keyPrefix).playlistOnStartup.playlistFile"
    private static let key_tracksFolder: String = "\(keyPrefix).playlistOnStartup.tracksFolder"
    
    private static let key_showNewTrackInPlaylist: String = "\(keyPrefix).showNewTrackInPlaylist"
    private static let key_showChaptersList: String = "\(keyPrefix).showChaptersList"
    
    private static let key_dragDropAddMode: String = "\(keyPrefix).dragDropAddMode"
    private static let key_openWithAddMode: String = "\(keyPrefix).openWithAddMode"
    
    internal required init(_ dict: [String: Any]) {
        
        playlistOnStartup = dict.enumValue(forKey: Self.key_playlistOnStartup, ofType: LegacyPlaylistStartupOptions.self)
        
        playlistFile = dict.urlValue(forKey: Self.key_playlistFile)
        
        showNewTrackInPlaylist = dict[Self.key_showNewTrackInPlaylist, Bool.self]
        
        showChaptersList = dict[Self.key_showChaptersList, Bool.self]
        
        // If .loadFile selected but no file available to load from, revert back to dict
        if playlistOnStartup == .loadFile && playlistFile == nil {
            playlistOnStartup = nil
        }
        
        tracksFolder = dict.urlValue(forKey: Self.key_tracksFolder)
        
        // If .loadFolder selected but no folder available to load from, revert back to dict
        if playlistOnStartup == .loadFolder && tracksFolder == nil {
            playlistOnStartup = nil
        }
        
        dragDropAddMode = dict.enumValue(forKey: Self.key_dragDropAddMode, ofType: LegacyPlaylistTracksAddMode.self)
        openWithAddMode = dict.enumValue(forKey: Self.key_openWithAddMode, ofType: LegacyPlaylistTracksAddMode.self)
    }
}

// All options for the playlist at startup
enum LegacyPlaylistStartupOptions: String, CaseIterable {
    
    case empty
    case rememberFromLastAppLaunch
    case loadFile
    case loadFolder
}

enum LegacyPlaylistTracksAddMode: String, CaseIterable {
    
    case append
    case replace
    case hybrid
}
