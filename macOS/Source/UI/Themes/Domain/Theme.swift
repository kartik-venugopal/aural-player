//
//  Theme.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
    let cornerRadius: CGFloat
    
    init(name: String, fontScheme: FontScheme, colorScheme: ColorScheme, cornerRadius: CGFloat, userDefined: Bool) {
        
        self.name = name
        self.fontScheme = fontScheme
        self.colorScheme = colorScheme
        self.cornerRadius = cornerRadius
        self.userDefined = userDefined
    }
    
    init?(persistentState: ThemePersistentState, systemDefined: Bool) {
        
        guard let persistentFontScheme = persistentState.fontScheme,
              let fontScheme = FontScheme(persistentState: persistentFontScheme, systemDefined: systemDefined),
              let persistentColorScheme = persistentState.colorScheme else {return nil}
        
        if systemDefined {
            
            self.name = persistentState.name ?? "_system_"
            
        } else {
            
            guard let name = persistentState.name else {return nil}
            self.name = name
        }
        
        self.userDefined = !systemDefined
        
        self.fontScheme = fontScheme
        self.colorScheme = ColorScheme(persistentColorScheme, systemDefined)
        self.cornerRadius = persistentState.cornerRadius ?? PlayerUIDefaults.cornerRadius
    }
    
    var persistentState: ThemePersistentState {
        ThemePersistentState(self)
    }
}
