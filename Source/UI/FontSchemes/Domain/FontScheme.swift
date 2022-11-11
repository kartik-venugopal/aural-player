//
//  FontScheme.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Container for fonts used by the UI
 */
class FontScheme: UserManagedObject {
    
    // Displayed name
    var name: String
    
    var key: String {
        
        get {name}
        set {name = newValue}
    }
    
    var userDefined: Bool {!systemDefined}

    // False if defined by the user
    let systemDefined: Bool
    
    var player: PlayerFontScheme
    var playlist: PlaylistFontScheme
    var effects: EffectsFontScheme
    
    // Used when loading app state on startup
    init(_ persistentState: FontSchemePersistentState?, _ systemDefined: Bool) {
        
        self.name = persistentState?.name ?? ""
        self.systemDefined = systemDefined
        
        self.player = PlayerFontScheme(persistentState)
        self.playlist = PlaylistFontScheme(persistentState)
        self.effects = EffectsFontScheme(persistentState)
    }
    
    init(_ name: String, _ preset: FontSchemePreset) {
        
        self.name = name
        self.systemDefined = true
        
        self.player = PlayerFontScheme(preset: preset)
        self.playlist = PlaylistFontScheme(preset: preset)
        self.effects = EffectsFontScheme(preset: preset)
    }
    
    init(_ name: String, _ systemDefined: Bool, _ fontScheme: FontScheme) {
        
        self.name = name
        self.systemDefined = systemDefined
        
        self.player = fontScheme.player.clone()
        self.playlist  = fontScheme.playlist.clone()
        self.effects = fontScheme.effects.clone()
    }
    
    func clone() -> FontScheme {
        return FontScheme(self.name + "_clone", self.systemDefined, self)
    }
}
