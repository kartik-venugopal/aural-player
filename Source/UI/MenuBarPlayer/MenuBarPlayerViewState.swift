//
//  MenuBarPlayerViewState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
class MenuBarPlayerViewState {
    
    static var showAlbumArt: Bool = MenuBarPlayerViewStateDefaults.showAlbumArt
    static var showArtist: Bool = MenuBarPlayerViewStateDefaults.showArtist
    static var showAlbum: Bool = MenuBarPlayerViewStateDefaults.showAlbum
    static var showCurrentChapter: Bool = MenuBarPlayerViewStateDefaults.showCurrentChapter
    
    static func initialize(_ persistentState: MenuBarPlayerUIPersistentState?) {
        
        showAlbumArt = persistentState?.showAlbumArt ?? MenuBarPlayerViewStateDefaults.showAlbumArt
        showArtist = persistentState?.showArtist ?? MenuBarPlayerViewStateDefaults.showArtist
        showAlbum = persistentState?.showAlbum ?? MenuBarPlayerViewStateDefaults.showAlbum
        showCurrentChapter = persistentState?.showCurrentChapter ?? MenuBarPlayerViewStateDefaults.showCurrentChapter
    }
    
    static var persistentState: MenuBarPlayerUIPersistentState {
        
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
