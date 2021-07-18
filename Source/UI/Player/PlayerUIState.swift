//
//  PlayerUIState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

// Convenient accessor for the current state of the player UI
class PlayerUIState {
    
    var viewType: PlayerViewType
    
    // Settings for individual track metadata fields
    
    var showAlbumArt: Bool
    var showArtist: Bool
    var showAlbum: Bool
    var showCurrentChapter: Bool
    
    var showTrackInfo: Bool
    
    var showPlayingTrackFunctions: Bool
    var showControls: Bool
    var showTimeElapsedRemaining: Bool
    
    var timeElapsedDisplayType: TimeElapsedDisplayType
    var timeRemainingDisplayType: TimeRemainingDisplayType
    
    init(persistentState: PlayerUIPersistentState?) {
        
        viewType = persistentState?.viewType ?? PlayerUIDefaults.viewType
        
        showAlbumArt = persistentState?.showAlbumArt ?? PlayerUIDefaults.showAlbumArt
        showArtist = persistentState?.showArtist ?? PlayerUIDefaults.showArtist
        showAlbum = persistentState?.showAlbum ?? PlayerUIDefaults.showAlbum
        showCurrentChapter = persistentState?.showCurrentChapter ?? PlayerUIDefaults.showCurrentChapter
        
        showTrackInfo = persistentState?.showTrackInfo ?? PlayerUIDefaults.showTrackInfo
        
        showPlayingTrackFunctions = persistentState?.showPlayingTrackFunctions ?? PlayerUIDefaults.showPlayingTrackFunctions
        showControls = persistentState?.showControls ?? PlayerUIDefaults.showControls
        showTimeElapsedRemaining = persistentState?.showTimeElapsedRemaining ?? PlayerUIDefaults.showTimeElapsedRemaining
        
        timeElapsedDisplayType = persistentState?.timeElapsedDisplayType ?? PlayerUIDefaults.timeElapsedDisplayType
        timeRemainingDisplayType = persistentState?.timeRemainingDisplayType ?? PlayerUIDefaults.timeRemainingDisplayType
    }
    
    var persistentState: PlayerUIPersistentState {
        
        PlayerUIPersistentState(viewType: viewType,
            showAlbumArt: showAlbumArt,
            showArtist: showArtist,
            showAlbum: showAlbum,
            showCurrentChapter: showCurrentChapter,
            showTrackInfo: showTrackInfo,
            showPlayingTrackFunctions: showPlayingTrackFunctions,
            showControls: showControls,
            showTimeElapsedRemaining: showTimeElapsedRemaining,
            timeElapsedDisplayType: timeElapsedDisplayType,
            timeRemainingDisplayType: timeRemainingDisplayType)
    }
}

struct PlayerUIDefaults {
    
    static let viewType: PlayerViewType = .defaultView
    
    static let showAlbumArt: Bool = true
    static let showArtist: Bool = true
    static let showAlbum: Bool = true
    static let showCurrentChapter: Bool = true
    
    static let showTrackInfo: Bool = true
    static let showSequenceInfo: Bool = true
    
    static let showPlayingTrackFunctions: Bool = true
    static let showControls: Bool = true
    static let showTimeElapsedRemaining: Bool = true
    
    static let timeElapsedDisplayType: TimeElapsedDisplayType = .formatted
    static let timeRemainingDisplayType: TimeRemainingDisplayType = .formatted
}

enum PlayerViewType: String, CaseIterable, Codable {
    
    case defaultView
    case expandedArt
}
