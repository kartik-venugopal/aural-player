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

class Theme: MappedPreset {
    
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
}
