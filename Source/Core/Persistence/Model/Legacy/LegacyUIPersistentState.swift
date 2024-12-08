//
//  LegacyUIPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct LegacyUIPersistentState: Codable {
    
    let appMode: LegacyAppMode?
    
//    let themes: ThemesPersistentState?
    let fontSchemes: LegacyFontSchemesPersistentState?
    let colorSchemes: LegacyColorSchemesPersistentState?
    let windowAppearance: LegacyWindowAppearancePersistentState?
    
    let player: LegacyPlayerUIPersistentState?
    let menuBarPlayer: LegacyMenuBarPlayerUIPersistentState?
    let controlBarPlayer: LegacyControlBarPlayerUIPersistentState?

    let visualizer: VisualizerUIPersistentState?
}

enum LegacyAppMode: String, CaseIterable, Codable {
    
    case windowed
    case menuBar
    case widget
}

struct LegacyPlayerUIPersistentState: Codable {
    
    let cornerRadius: CGFloat?
    
    let showAlbumArt: Bool?
    let showArtist: Bool?
    let showAlbum: Bool?
    let showCurrentChapter: Bool?
    
    let showControls: Bool?
    let showTimeElapsedRemaining: Bool?
}

struct LegacyMenuBarPlayerUIPersistentState: Codable {
    
    let showAlbumArt: Bool?
    let showArtist: Bool?
    let showAlbum: Bool?
    let showCurrentChapter: Bool?
}

struct LegacyControlBarPlayerUIPersistentState: Codable {
    
    let windowFrame: NSRect?
    let cornerRadius: CGFloat?
    
    let trackInfoScrollingEnabled: Bool?
    let showSeekPosition: Bool?
}

struct LegacyWindowAppearancePersistentState: Codable {
    
    let cornerRadius: CGFloat?
}
