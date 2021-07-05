//
//  FontSchemesPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Encapsulates all persistent app state for color schemes.
 */
struct FontSchemesPersistentState: Codable {

    let systemScheme: FontSchemePersistentState?
    let userSchemes: [FontSchemePersistentState]?
}

/*
    Encapsulates persistent app state for a single font scheme.
 */
struct FontSchemePersistentState: Codable {

    let name: String?
    
    let textFontName: String?
    let headingFontName: String?

    let player: PlayerFontSchemePersistentState?
    let playlist: PlaylistFontSchemePersistentState?
    let effects: EffectsFontSchemePersistentState?

    // When saving app state to disk
    init(_ scheme: FontScheme) {

        self.name = scheme.name
        
        self.textFontName = scheme.player.infoBoxTitleFont.fontName
        self.headingFontName = scheme.playlist.tabButtonTextFont.fontName

        self.player = PlayerFontSchemePersistentState(scheme.player)
        self.playlist = PlaylistFontSchemePersistentState(scheme.playlist)
        self.effects = EffectsFontSchemePersistentState(scheme.effects)
    }
}
