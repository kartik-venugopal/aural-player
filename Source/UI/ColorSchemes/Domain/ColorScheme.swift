//
//  ColorScheme.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Encapsulates all colors that determine a color scheme that can be appplied to the entire application.
 */
class ColorScheme: MappedPreset {
    
    // Displayed name
    var name: String
    
    var key: String {
        
        get {name}
        set {name = newValue}
    }
    
    var userDefined: Bool {!systemDefined}

    // False if defined by the user
    let systemDefined: Bool

    var general: GeneralColorScheme
    var player: PlayerColorScheme
    var playlist: PlaylistColorScheme
    var effects: EffectsColorScheme
    
    // Utility function (for debugging purposes only)
    func toString() -> String {
        return String(describing: JSONMapper.map(ColorSchemePersistentState(self)))
    }
    
    // Copy constructor ... creates a copy of the given scheme (used when creating a user-defined preset)
    init(_ name: String, _ systemDefined: Bool, _ scheme: ColorScheme) {
    
        self.name = name
        self.systemDefined = systemDefined
        
        self.general = scheme.general.clone()
        self.player = scheme.player.clone()
        self.playlist = scheme.playlist.clone()
        self.effects = scheme.effects.clone()
    }
    
    // Used when loading app state on startup
    init(_ persistentState: ColorSchemePersistentState?, _ systemDefined: Bool) {
        
        self.name = persistentState?.name ?? ""
        self.systemDefined = systemDefined
        
        self.general = GeneralColorScheme(persistentState?.general)
        self.player = PlayerColorScheme(persistentState?.player)
        self.playlist = PlaylistColorScheme(persistentState?.playlist)
        self.effects = EffectsColorScheme(persistentState?.effects)
    }
    
    // Creates a scheme from a preset (eg. default scheme)
    init(_ name: String, _ preset: ColorSchemePreset) {
        
        self.name = name
        self.systemDefined = true
        
        self.general = GeneralColorScheme(preset)
        self.player = PlayerColorScheme(preset)
        self.playlist = PlaylistColorScheme(preset)
        self.effects = EffectsColorScheme(preset)
    }
    
    // Applies a system-defined preset to this scheme.
    func applyPreset(_ preset: ColorSchemePreset) {
        
        self.general.applyPreset(preset)
        self.player.applyPreset(preset)
        self.playlist.applyPreset(preset)
        self.effects.applyPreset(preset)
    }
    
    // Applies another color scheme to this scheme.
    func applyScheme(_ scheme: ColorScheme) {
        
        self.general.applyScheme(scheme.general)
        self.player.applyScheme(scheme.player)
        self.playlist.applyScheme(scheme.playlist)
        self.effects.applyScheme(scheme.effects)
    }
    
    // Creates an identical copy of this color scheme
    func clone() -> ColorScheme {
        return ColorScheme(self.name + "_clone", self.systemDefined, self)
    }
    
    // State that can be persisted to disk
    var persistentState: ColorSchemePersistentState {
        return ColorSchemePersistentState(self)
    }
}

/*
    Enumerates all different types of gradients that can be applied to colors in a color scheme.
 */
enum ColorSchemeGradientType: String, CaseIterable, Codable {
    
    case none
    case darken
    case brighten
}

// A contract for any UI component that marks it as being able to apply a color scheme to itself.
protocol ColorSchemeable {
    
    // Apply the given color scheme to this component.
    func applyColorScheme(_ scheme: ColorScheme)
}
