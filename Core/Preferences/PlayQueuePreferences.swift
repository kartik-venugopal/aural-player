//
//  PlayQueuePreferences.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// Encapsulates all user preferences pertaining to the Play Queue.
///
class PlayQueuePreferences {
    
    private typealias Defaults = PreferencesDefaults.PlayQueue
    
    // ------ MARK: Property keys ---------
    
    private static let keyPrefix: String = "playQueue"
    
    lazy var playQueueOnStartup: UserPreference<PlayQueueStartupOption> = .init(defaultsKey: "\(Self.keyPrefix).playQueueOnStartup",
                                                                                defaultValue: Defaults.playQueueOnStartup)
    
    // This will be used only when playQueueOnStartup == PlayQueueStartupOption.loadFile
    lazy var playlistFile: OptionalUserPreference<URL> = .init(defaultsKey: "\(Self.keyPrefix).playQueueOnStartup.playlistFile")
    
    lazy var tracksFolder: OptionalUserPreference<URL> = .init(defaultsKey: "\(Self.keyPrefix).playQueueOnStartup.tracksFolder")
    
    lazy var showNewTrackInPlayQueue: UserPreference<Bool> = .init(defaultsKey: "\(Self.keyPrefix).showNewTrackInPlayQueue",
                                                                   defaultValue: Defaults.showNewTrackInPlayQueue)
    
    lazy var showChaptersList: UserPreference<Bool> = .init(defaultsKey: "\(Self.keyPrefix).showChaptersList",
                                                            defaultValue: Defaults.showChaptersList)
    
    lazy var dragDropAddMode: UserPreference<PlayQueueTracksAddMode> = .init(defaultsKey: "\(Self.keyPrefix).dragDropAddMode",
                                                                             defaultValue: Defaults.dragDropAddMode)
    
    lazy var openWithAddMode: UserPreference<PlayQueueTracksAddMode> = .init(defaultsKey: "\(Self.keyPrefix).openWithAddMode",
                                                                             defaultValue: Defaults.openWithAddMode)
    
    init(legacyPreferences: LegacyPlaylistPreferences? = nil) {
        
        guard let legacyPreferences = legacyPreferences else {return}
        
        if let playlistOnStartup = legacyPreferences.playlistOnStartup {
            
            self.playQueueOnStartup.value = .fromLegacyPlaylistStartupOption(playlistOnStartup)
            
            switch playlistOnStartup {
            
            case .loadFile:
                self.playlistFile.value = legacyPreferences.playlistFile
                
            case .loadFolder:
                self.tracksFolder.value = legacyPreferences.tracksFolder
                
            default:
                break
            }
        }
        
        if let showNewTrackInPlaylist = legacyPreferences.showNewTrackInPlaylist {
            self.showNewTrackInPlayQueue.value = showNewTrackInPlaylist
        }
        
        if let showChaptersList = legacyPreferences.showChaptersList {
            self.showChaptersList.value = showChaptersList
        }
        
        if let dragDropAddMode = legacyPreferences.dragDropAddMode {
            self.dragDropAddMode.value = .fromLegacyPlaylistTracksAddMode(dragDropAddMode)
        }
        
        if let openWithAddMode = legacyPreferences.openWithAddMode {
            self.openWithAddMode.value = .fromLegacyPlaylistTracksAddMode(openWithAddMode)
        }
    }
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
