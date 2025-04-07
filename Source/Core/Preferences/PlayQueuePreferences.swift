//
//  PlayQueuePreferences.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// Encapsulates all user preferences pertaining to the Play Queue.
///
class PlayQueuePreferences {
    
    @EnumUserPreference(key: "playQueue.playQueueOnStartup", defaultValue: Defaults.playQueueOnStartup)
    var playQueueOnStartup: PlayQueueStartupOption
    
    // This will be used only when playQueueOnStartup == PlayQueueStartupOption.loadFile
    @URLUserPreference(key: "playQueue.playQueueOnStartup.playlistFile")
    var playlistFile: URL?
    
    @URLUserPreference(key: "playQueue.playQueueOnStartup.tracksFolder")
    var tracksFolder: URL?
    
    @UserPreference(key: "playQueue.showNewTrackInPlayQueue", defaultValue: Defaults.showNewTrackInPlayQueue)
    var showNewTrackInPlayQueue: Bool
    
    @UserPreference(key: "playQueue.showChaptersList", defaultValue: Defaults.showChaptersList)
    var showChaptersList: Bool
    
    @EnumUserPreference(key: "playQueue.dragDropAddMode", defaultValue: Defaults.dragDropAddMode)
    var dragDropAddMode: PlayQueueTracksAddMode
    
    @EnumUserPreference(key: "playQueue.openWithAddMode", defaultValue: Defaults.openWithAddMode)
    var openWithAddMode: PlayQueueTracksAddMode
    
    init(legacyPreferences: LegacyPlaylistPreferences? = nil) {
        
        guard let legacyPreferences = legacyPreferences else {return}
        
        if let playlistOnStartup = legacyPreferences.playlistOnStartup {
            
            self.playQueueOnStartup = .fromLegacyPlaylistStartupOption(playlistOnStartup)
            
            switch playlistOnStartup {
            
            case .loadFile:
                self.playlistFile = legacyPreferences.playlistFile
                
            case .loadFolder:
                self.tracksFolder = legacyPreferences.tracksFolder
                
            default:
                break
            }
        }
        
        if let showNewTrackInPlaylist = legacyPreferences.showNewTrackInPlaylist {
            self.showNewTrackInPlayQueue = showNewTrackInPlaylist
        }
        
        if let showChaptersList = legacyPreferences.showChaptersList {
            self.showChaptersList = showChaptersList
        }
        
        if let dragDropAddMode = legacyPreferences.dragDropAddMode {
            self.dragDropAddMode = .fromLegacyPlaylistTracksAddMode(dragDropAddMode)
        }
        
        if let openWithAddMode = legacyPreferences.openWithAddMode {
            self.openWithAddMode = .fromLegacyPlaylistTracksAddMode(openWithAddMode)
        }
        
        legacyPreferences.deleteAll()
    }
    
    // All options for the Play Queue at startup
    enum PlayQueueStartupOption: String, CaseIterable, Codable {
        
        case empty
        case rememberFromLastAppLaunch
        case loadPlaylistFile
        case loadFolder
        
        static func fromLegacyPlaylistStartupOption(_ option: LegacyPlaylistStartupOptions) -> PlayQueueStartupOption {
            
            switch option {
                
            case .empty:
                return .empty
                
            case .rememberFromLastAppLaunch:
                return .rememberFromLastAppLaunch
                
            case .loadFile:
                return .loadPlaylistFile
                
            case .loadFolder:
                return .loadFolder
            }
        }
    }

    enum PlayQueueTracksAddMode: String, CaseIterable, Codable {
        
        case append
        case replace
        case hybrid
        
        static func fromLegacyPlaylistTracksAddMode(_ mode: LegacyPlaylistTracksAddMode) -> PlayQueueTracksAddMode {
            
            switch mode {
            
            case .append:
                return .append
                
            case .replace:
                return .replace
                
            case .hybrid:
                return .hybrid
            }
        }
    }
    
    ///
    /// An enumeration of default values for Play Queue preferences.
    ///
    fileprivate struct Defaults {
        
        static let playQueueOnStartup: PlayQueueStartupOption = .rememberFromLastAppLaunch
        
        static let showNewTrackInPlayQueue: Bool = true
        static let showChaptersList: Bool = true
        
        static let dragDropAddMode: PlayQueueTracksAddMode = .append
        static let openWithAddMode: PlayQueueTracksAddMode = .append
    }
}
