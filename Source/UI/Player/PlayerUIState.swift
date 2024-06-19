//
//  PlayerUIState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

// Convenient accessor for the current state of the player UI
class PlayerUIState {
    
    var cornerRadius: CGFloat
    
    // Settings for individual track metadata fields
    var showAlbumArt: Bool
    var showArtist: Bool
    var showAlbum: Bool
    var showCurrentChapter: Bool
    
    var showControls: Bool
    var showPlaybackPosition: Bool
    
    var playbackPositionDisplayType: PlaybackPositionDisplayType
    
    init(persistentState: ModularPlayerUIPersistentState?) {
        
        cornerRadius = persistentState?.cornerRadius ?? PlayerUIDefaults.cornerRadius
        
        showAlbumArt = persistentState?.showAlbumArt ?? PlayerUIDefaults.showAlbumArt
        showArtist = persistentState?.showArtist ?? PlayerUIDefaults.showArtist
        showAlbum = persistentState?.showAlbum ?? PlayerUIDefaults.showAlbum
        showCurrentChapter = persistentState?.showCurrentChapter ?? PlayerUIDefaults.showCurrentChapter
        
        showControls = persistentState?.showControls ?? PlayerUIDefaults.showControls
        showPlaybackPosition = persistentState?.showPlaybackPosition ?? PlayerUIDefaults.showPlaybackPosition
        
        playbackPositionDisplayType = persistentState?.playbackPositionDisplayType ?? PlayerUIDefaults.playbackPositionDisplayType
    }
    
    var persistentState: ModularPlayerUIPersistentState {
        
        ModularPlayerUIPersistentState(cornerRadius: cornerRadius,
                                       showAlbumArt: showAlbumArt,
                                       showArtist: showArtist,
                                       showAlbum: showAlbum,
                                       showCurrentChapter: showCurrentChapter,
                                       showControls: showControls,
                                       showPlaybackPosition: showPlaybackPosition,
                                       playbackPositionDisplayType: playbackPositionDisplayType)
    }
}

struct PlayerUIDefaults {
    
    static let cornerRadius: CGFloat = 2
    
    static let showAlbumArt: Bool = true
    static let showArtist: Bool = true
    static let showAlbum: Bool = true
    static let showCurrentChapter: Bool = true
    
    static let showControls: Bool = true
    static let showPlaybackPosition: Bool = true
    
    static let playbackPositionDisplayType: PlaybackPositionDisplayType = .elapsed
}
