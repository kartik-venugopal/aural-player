//
//  MenuBarPlayerUIState.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
class MenuBarPlayerUIState {
    
    var showAlbumArt: Bool
    var showArtist: Bool
    var showAlbum: Bool
    var showCurrentChapter: Bool
    
    init(persistentState: MenuBarPlayerUIPersistentState?) {
        
        showAlbumArt = persistentState?.showAlbumArt ?? MenuBarPlayerUIDefaults.showAlbumArt
        showArtist = persistentState?.showArtist ?? MenuBarPlayerUIDefaults.showArtist
        showAlbum = persistentState?.showAlbum ?? MenuBarPlayerUIDefaults.showAlbum
        showCurrentChapter = persistentState?.showCurrentChapter ?? MenuBarPlayerUIDefaults.showCurrentChapter
    }
    
    var persistentState: MenuBarPlayerUIPersistentState {
        
        MenuBarPlayerUIPersistentState(showAlbumArt: showAlbumArt,
                                       showArtist: showArtist,
                                       showAlbum: showAlbum,
                                       showCurrentChapter: showCurrentChapter)
    }
}

class MenuBarPlayerUIDefaults {
    
    static let showAlbumArt: Bool = true
    static let showArtist: Bool = true
    static let showAlbum: Bool = true
    static let showCurrentChapter: Bool = true
}
