//
//  ColorSchemesPersistentState.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// Encapsulates all persistent state for application color schemes.
///
/// - SeeAlso: `ColorSchemesManager`
///
struct ColorSchemesPersistentState: Codable {

    let systemScheme: ColorSchemePersistentState?
    let userSchemes: [ColorSchemePersistentState]?
}

///
/// Persistent state for a single color scheme.
///
/// - SeeAlso: `ColorScheme`
///
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
