//
//  MenuBarPlayerUIState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
        
        showAlbumArt = persistentState?.showAlbumArt ?? MenuBarPlayerViewStateDefaults.showAlbumArt
        showArtist = persistentState?.showArtist ?? MenuBarPlayerViewStateDefaults.showArtist
        showAlbum = persistentState?.showAlbum ?? MenuBarPlayerViewStateDefaults.showAlbum
        showCurrentChapter = persistentState?.showCurrentChapter ?? MenuBarPlayerViewStateDefaults.showCurrentChapter
    }
    
    var persistentState: MenuBarPlayerUIPersistentState {
        
        MenuBarPlayerUIPersistentState(showAlbumArt: showAlbumArt,
                                       showArtist: showArtist,
                                       showAlbum: showAlbum,
                                       showCurrentChapter: showCurrentChapter)
    }
}

class MenuBarPlayerViewStateDefaults {
    
    static let showAlbumArt: Bool = true
    static let showArtist: Bool = true
    static let showAlbum: Bool = true
    static let showCurrentChapter: Bool = true
}
