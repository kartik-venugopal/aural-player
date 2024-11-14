//
//  ThemesManager.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Utility class that manages all themes, including user-defined schemes, system-defined presets, and the current system theme.
 */
class ThemesManager: UserManagedObjects<Theme> {
    
    private lazy var messenger = Messenger(for: self)
    
    init(persistentState: ThemesPersistentState?, fontSchemesManager: FontSchemesManager) {
        
        let systemDefinedThemes = ThemePreset.allCases.map {$0.theme}
        
        let userDefinedThemes: [Theme] = (persistentState?.userThemes ?? []).compactMap {Theme(persistentState: $0, systemDefined: false)}
        
        super.init(systemDefinedObjects: systemDefinedThemes, userDefinedObjects: userDefinedThemes)
    }
    
    // Applies a theme to the system theme and returns the modified system scheme.
    func applyTheme(_ theme: Theme) {
        
        fontSchemesManager.applyScheme(theme.fontScheme)
        colorSchemesManager.applyScheme(theme.colorScheme)

        playerUIState.cornerRadius = theme.cornerRadius
        Messenger.publish(.View.changeWindowCornerRadius, payload: playerUIState.cornerRadius)
    }
    
    // Attempts to apply a theme to the system theme, looking up the scheme by the given display name, and if found, returns the modified system scheme.
    func applyTheme(named name: String) {
        
        if let theme = object(named: name) {
            applyTheme(theme)
        }
    }
    
    // State to be persisted to disk.
    var persistentState: ThemesPersistentState {
        ThemesPersistentState(userThemes: userDefinedObjects.map {ThemePersistentState($0)})
    }
}
