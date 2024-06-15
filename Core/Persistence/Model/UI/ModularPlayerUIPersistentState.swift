//
//  PlayerUIPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for the Player UI.
///
/// - SeeAlso: `PlayerUIState`
///
struct ModularPlayerUIPersistentState: Codable {
    
    let cornerRadius: CGFloat?
    
    let showAlbumArt: Bool?
    let showArtist: Bool?
    let showAlbum: Bool?
    let showCurrentChapter: Bool?
    
    let showControls: Bool?
    let showPlaybackPosition: Bool?
    
    let playbackPositionDisplayType: PlaybackPositionDisplayType?
    
    init(cornerRadius: CGFloat?, showAlbumArt: Bool?, showArtist: Bool?, showAlbum: Bool?, showCurrentChapter: Bool?, showControls: Bool?, showPlaybackPosition: Bool?, playbackPositionDisplayType: PlaybackPositionDisplayType?) {
        
        self.cornerRadius = cornerRadius
        
        self.showAlbumArt = showAlbumArt
        self.showArtist = showArtist
        self.showAlbum = showAlbum
        self.showCurrentChapter = showCurrentChapter
        self.showControls = showControls
        self.showPlaybackPosition = showPlaybackPosition
        self.playbackPositionDisplayType = playbackPositionDisplayType
    }
    
    init(legacyPersistentState: LegacyPlayerUIPersistentState?, legacyWindowAppearanceState: LegacyWindowAppearancePersistentState?) {
        
        self.cornerRadius = legacyWindowAppearanceState?.cornerRadius
        
        self.showAlbumArt = legacyPersistentState?.showAlbumArt
        self.showArtist = legacyPersistentState?.showArtist
        self.showAlbum = legacyPersistentState?.showAlbum
        self.showCurrentChapter = legacyPersistentState?.showCurrentChapter
        
        self.showControls = legacyPersistentState?.showControls
        self.showPlaybackPosition = legacyPersistentState?.showTimeElapsedRemaining
        
        self.playbackPositionDisplayType = nil
    }
}
