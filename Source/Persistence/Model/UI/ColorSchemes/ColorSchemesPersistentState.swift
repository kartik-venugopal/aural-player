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
class ColorSchemesPersistentState: PersistentStateProtocol {

    let userSchemes: [ColorSchemePersistentState]?
    let systemScheme: ColorSchemePersistentState?
    
    init(_ systemScheme: ColorSchemePersistentState, _ userSchemes: [ColorSchemePersistentState]) {
        
        self.systemScheme = systemScheme
        self.userSchemes = userSchemes
    }
    
    required init?(_ map: NSDictionary) {
        
        self.userSchemes = map.persistentObjectArrayValue(forKey: "userSchemes", ofType: ColorSchemePersistentState.self)
        self.systemScheme = map.persistentObjectValue(forKey: "systemScheme", ofType: ColorSchemePersistentState.self)
    }
}

/*
    Encapsulates persistent app state for a single color scheme.
 */
class ColorSchemePersistentState: PersistentStateProtocol {
    
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
    
    required init?(_ map: NSDictionary) {
        
        guard let name = map.nonEmptyStringValue(forKey: "name") else {return nil}
        self.name = name
        
        self.general = map.persistentObjectValue(forKey: "general", ofType: GeneralColorSchemePersistentState.self)
        self.player = map.persistentObjectValue(forKey: "player", ofType: PlayerColorSchemePersistentState.self)
        self.playlist = map.persistentObjectValue(forKey: "playlist", ofType: PlaylistColorSchemePersistentState.self)
        self.effects = map.persistentObjectValue(forKey: "effects", ofType: EffectsColorSchemePersistentState.self)
    }
}
