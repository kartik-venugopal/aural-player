//
//  MenuBarPlayerUIPersistentState.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for the Menu Bar app mode's UI.
///
/// - SeeAlso: `MenuBarPlayerUIState`
///
struct MenuBarPlayerUIPersistentState: Codable {
    
    let showPlayQueue: Bool?
    let showAlbumArt: Bool?
    let showArtist: Bool?
    let showAlbum: Bool?
    let showCurrentChapter: Bool?
    
    init(showPlayQueue: Bool?, showAlbumArt: Bool?, showArtist: Bool?, showAlbum: Bool?, showCurrentChapter: Bool?) {
        
        self.showPlayQueue = showPlayQueue
        self.showAlbumArt = showAlbumArt
        self.showArtist = showArtist
        self.showAlbum = showAlbum
        self.showCurrentChapter = showCurrentChapter
    }
    
    init(legacyPersistentState: LegacyMenuBarPlayerUIPersistentState?) {
        
        self.showPlayQueue = nil
        
        self.showAlbumArt = legacyPersistentState?.showAlbumArt
        self.showArtist = legacyPersistentState?.showArtist
        self.showAlbum = legacyPersistentState?.showAlbum
        self.showCurrentChapter = legacyPersistentState?.showCurrentChapter
    }
}
