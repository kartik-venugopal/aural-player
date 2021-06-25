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
}

class MenuBarPlayerViewStateDefaults {
    
    static let showAlbumArt: Bool = true
    static let showArtist: Bool = true
    static let showAlbum: Bool = true
    static let showCurrentChapter: Bool = true
}
