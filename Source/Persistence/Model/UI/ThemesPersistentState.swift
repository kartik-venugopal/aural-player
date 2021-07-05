//
//  ThemesPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

struct ThemesPersistentState: Codable {
    
    let userThemes: [ThemePersistentState]?
}

struct ThemePersistentState: Codable {
    
    let name: String?
    
    let fontScheme: FontSchemePersistentState?
    let colorScheme: ColorSchemePersistentState?
    let windowAppearance: WindowUIPersistentState?
    
    init(_ theme: Theme) {
        
        self.name = theme.name
        self.fontScheme = FontSchemePersistentState(theme.fontScheme)
        self.colorScheme = ColorSchemePersistentState(theme.colorScheme)
        self.windowAppearance = WindowUIPersistentState(cornerRadius: theme.windowAppearance.cornerRadius)
    }
}

extension Theme: PersistentModelObject {
    
    var persistentState: ThemePersistentState {
        ThemePersistentState(self)
    }
}
