//
//  ColorSchemesManager.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Utility class that manages all color schemes, including user-defined schemes, system-defined presets, and the current system color scheme.
 */
class ColorSchemesManager: MappedPresets<ColorScheme> {
    
    // The current system color scheme. It is initialized with the default scheme.
    private(set) var systemScheme: ColorScheme = ColorScheme("_system_", ColorSchemePreset.defaultScheme) {
        didSet {systemSchemeChanged()}
    }
    
    private lazy var messenger = Messenger(for: self)
    
    init(persistentState: ColorSchemesPersistentState?) {
        
        let systemDefinedSchemes = ColorSchemePreset.allCases.map {ColorScheme($0.name, $0)}
        let userDefinedSchemes = (persistentState?.userSchemes ?? []).map {ColorScheme($0, false)}
        
        if let persistentSystemScheme = persistentState?.systemScheme {
            
            self.systemScheme = ColorScheme(persistentSystemScheme, true)
            
        } else {
            
            self.systemScheme = systemDefinedSchemes.first(where: {$0.name == ColorSchemePreset.defaultScheme.name}) ??
                ColorScheme("_system_", ColorSchemePreset.defaultScheme)
        }
        
        super.init(systemDefinedPresets: systemDefinedSchemes, userDefinedPresets: userDefinedSchemes)
    }
    
    private func systemSchemeChanged() {
        
        // Update color / gradient caches whenever the system scheme changes.
        Colors.Player.updateSliderColors()
        AuralPlaylistOutlineView.updateCachedImages()
    }
    
    // Applies a color scheme to the system color scheme and returns the modified system scheme.
    func applyScheme(_ scheme: ColorScheme) {
        
        systemScheme.applyScheme(scheme)
        systemSchemeChanged()
        
        messenger.publish(.applyColorScheme, payload: systemScheme)
    }
    
    // Attempts to apply a color scheme to the system color scheme, looking up the scheme by the given display name, and if found, returns the modified system scheme.
    func applyScheme(named name: String) {
        
        if let scheme = preset(named: name) {
            applyScheme(scheme)
        }
    }
    
    // State to be persisted to disk.
    var persistentState: ColorSchemesPersistentState {
        
        ColorSchemesPersistentState(systemScheme: ColorSchemePersistentState(systemScheme),
                                    userSchemes: userDefinedPresets.map {ColorSchemePersistentState($0)})
    }
}
