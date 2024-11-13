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
    
    let windowLayout: WindowLayoutsPersistentState?
    
    init(cornerRadius: CGFloat?, showAlbumArt: Bool?, showArtist: Bool?, showAlbum: Bool?, showCurrentChapter: Bool?, showControls: Bool?, showPlaybackPosition: Bool?, playbackPositionDisplayType: PlaybackPositionDisplayType?, windowLayout: WindowLayoutsPersistentState?) {
        
        self.cornerRadius = cornerRadius
        
        self.showAlbumArt = showAlbumArt
        self.showArtist = showArtist
        self.showAlbum = showAlbum
        self.showCurrentChapter = showCurrentChapter
        self.showControls = showControls
        self.showPlaybackPosition = showPlaybackPosition
        self.playbackPositionDisplayType = playbackPositionDisplayType
        self.windowLayout = windowLayout
    }
    
    init(legacyPersistentState: LegacyUIPersistentState?) {
        
        self.cornerRadius = legacyPersistentState?.windowAppearance?.cornerRadius
        
        self.showAlbumArt = legacyPersistentState?.player?.showAlbumArt
        self.showArtist = legacyPersistentState?.player?.showArtist
        self.showAlbum = legacyPersistentState?.player?.showAlbum
        self.showCurrentChapter = legacyPersistentState?.player?.showCurrentChapter
        
        self.showControls = legacyPersistentState?.player?.showControls
        self.showPlaybackPosition = legacyPersistentState?.player?.showTimeElapsedRemaining
        self.playbackPositionDisplayType = nil
        
        self.windowLayout = nil
    }
}
