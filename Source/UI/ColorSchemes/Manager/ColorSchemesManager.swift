//
//  ColorSchemesManager.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Utility class that manages all color schemes, including user-defined schemes, system-defined presets, and the current system color scheme.
 */
class ColorSchemesManager: UserManagedObjects<ColorScheme> {
    
    // The current system color scheme. It is initialized with the default scheme.
    let systemScheme: ColorScheme
    
    private lazy var messenger = Messenger(for: self)
    
    var propertyObservers: [ColorSchemeProperty: [Int: [ColorSchemePropertyChangeHandler]]] = [:]
    var schemeObservers: [Int: ColorSchemeObserver] = [:]
    
    var isObserving: Bool = false
    var schemeChanged: Bool = false
    
    init(persistentState: ColorSchemesPersistentState?) {
        
        let systemDefinedSchemes: [ColorScheme] = ColorScheme.allSystemDefinedSchemes
        let userDefinedSchemes = (persistentState?.userSchemes ?? []).map {ColorScheme($0, false)}
        
        if let persistentSystemScheme = persistentState?.systemScheme {
            self.systemScheme = ColorScheme(persistentSystemScheme, true)
            
        } else {
            self.systemScheme = ColorScheme("_system_", true, .defaultScheme)
        }
        
        super.init(systemDefinedObjects: systemDefinedSchemes, userDefinedObjects: userDefinedSchemes)
    }
    
    private func systemSchemeChanged() {
        
        // Update color / gradient caches whenever the system scheme changes.
//        AuralPlaylistOutlineView.updateCachedImages()
        
        schemeObservers.values.forEach {
            $0.colorSchemeChanged()
        }
    }
    
    // Applies a color scheme to the system color scheme and returns the modified system scheme.
    func applyScheme(_ scheme: ColorScheme) {
        
        schemeChanged = true
        
        systemScheme.applyScheme(scheme)
        systemSchemeChanged()
        
        schemeChanged = false
    }
    
    // Attempts to apply a color scheme to the system color scheme, looking up the scheme by the given display name, and if found, returns the modified system scheme.
    func applyScheme(named name: String) {
        
        if let scheme = object(named: name) {
            applyScheme(scheme)
        }
    }
    
    // State to be persisted to disk.
    var persistentState: ColorSchemesPersistentState {
        
        ColorSchemesPersistentState(systemScheme: ColorSchemePersistentState(systemScheme),
                                    userSchemes: userDefinedObjects.map {ColorSchemePersistentState($0)})
    }
}
