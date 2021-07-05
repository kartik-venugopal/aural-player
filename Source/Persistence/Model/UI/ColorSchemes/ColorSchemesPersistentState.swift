//
//  ColorSchemesPersistentState.swift
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
struct ColorSchemesPersistentState: Codable {

    let systemScheme: ColorSchemePersistentState?
    let userSchemes: [ColorSchemePersistentState]?
}

/*
    Encapsulates persistent app state for a single color scheme.
 */
struct ColorSchemePersistentState: Codable {
    
    let name: String
    
    let general: GeneralColorSchemePersistentState?
    let player: PlayerColorSchemePersistentState?
    let playlist: PlaylistColorSchemePersistentState?
    let effects: EffectsColorSchemePersistentState?
    
    // When saving app state to disk
    init(_ scheme: ColorScheme) {
        
        self.name = scheme.name
        
        self.general = GeneralColorSchemePersistentState(scheme.general)
        self.player = PlayerColorSchemePersistentState(scheme.player)
        self.playlist = PlaylistColorSchemePersistentState(scheme.playlist)
        self.effects = EffectsColorSchemePersistentState(scheme.effects)
    }
}
