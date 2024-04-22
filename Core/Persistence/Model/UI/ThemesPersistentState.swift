//
//  ThemesPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all persistent state for application themes.
///
/// - SeeAlso: `ThemesManager`
///
struct ThemesPersistentState: Codable {
    
    let userThemes: [ThemePersistentState]?
}

///
/// Persistent state for a single theme.
///
/// - SeeAlso: `Theme`
///
struct ThemePersistentState: Codable {
    
    let name: String?
    
    let fontScheme: FontSchemePersistentState?
    let colorScheme: ColorSchemePersistentState?
    let cornerRadius: CGFloat?
    
#if os(macOS)
    
    init(_ theme: Theme) {
        
        self.name = theme.name
        self.fontScheme = FontSchemePersistentState(theme.fontScheme)
        self.colorScheme = ColorSchemePersistentState(theme.colorScheme)
        self.cornerRadius = theme.cornerRadius
    }
    
#endif
}
