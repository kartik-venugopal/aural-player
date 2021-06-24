//
//  MenuBarPlayerUIPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class MenuBarPlayerUIPersistentState: PersistentStateProtocol {
    
    var showAlbumArt: Bool?
    var showArtist: Bool?
    var showAlbum: Bool?
    var showCurrentChapter: Bool?
    
    init() {}
    
    required init?(_ map: NSDictionary) {
        
        self.showAlbumArt = map["showAlbumArt", Bool.self]
        self.showArtist = map["showArtist", Bool.self]
        self.showAlbum = map["showAlbum", Bool.self]
        self.showCurrentChapter = map["showCurrentChapter", Bool.self]
    }
}

extension MenuBarPlayerViewState {
    
    static func initialize(_ persistentState: MenuBarPlayerUIPersistentState?) {
        
        showAlbumArt = persistentState?.showAlbumArt ?? MenuBarPlayerViewStateDefaults.showAlbumArt
        showArtist = persistentState?.showArtist ?? MenuBarPlayerViewStateDefaults.showArtist
        showAlbum = persistentState?.showAlbum ?? MenuBarPlayerViewStateDefaults.showAlbum
        showCurrentChapter = persistentState?.showCurrentChapter ?? MenuBarPlayerViewStateDefaults.showCurrentChapter
    }
    
    static var persistentState: MenuBarPlayerUIPersistentState {
        
        let state = MenuBarPlayerUIPersistentState()
        
        state.showAlbumArt = showAlbumArt
        state.showArtist = showArtist
        state.showAlbum = showAlbum
        state.showCurrentChapter = showCurrentChapter
        
        return state
    }
}

