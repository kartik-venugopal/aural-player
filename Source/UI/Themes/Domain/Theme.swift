//
//  Theme.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class Theme: UserManagedObject, PersistentModelObject {
    
    var name: String
    
    var key: String {
        
        get {name}
        set {name = newValue}
    }
    
    let userDefined: Bool
    
    let fontScheme: FontScheme
    let colorScheme: ColorScheme
    let windowAppearance: WindowAppearance
    
    init(name: String, fontScheme: FontScheme, colorScheme: ColorScheme, windowAppearance: WindowAppearance, userDefined: Bool) {
        
        self.name = name
        self.fontScheme = fontScheme
        self.colorScheme = colorScheme
        self.windowAppearance = windowAppearance
        self.userDefined = userDefined
    }
    
    init?(persistentState: ThemePersistentState, systemDefined: Bool) {
        
        guard let persistentFontScheme = persistentState.fontScheme,
              let persistentColorScheme = persistentState.colorScheme else {return nil}
        
        if systemDefined {
            
            self.name = persistentState.name ?? "_system_"
            
        } else {
            
            guard let name = persistentState.name else {return nil}
            self.name = name
        }
        
        self.userDefined = !systemDefined
        
        self.fontScheme = FontScheme(persistentFontScheme, systemDefined)
        self.colorScheme = ColorScheme(persistentColorScheme, systemDefined)
        self.windowAppearance = WindowAppearance(cornerRadius: persistentState.windowAppearance?.cornerRadius ?? WindowAppearanceState.defaultCornerRadius)
    }
    
    var persistentState: ThemePersistentState {
        ThemePersistentState(self)
    }
}
