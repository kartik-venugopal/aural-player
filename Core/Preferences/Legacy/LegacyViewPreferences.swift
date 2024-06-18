//
//  LegacyViewPreferences.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class LegacyViewPreferences {
    
    private static let keyPrefix: String = "view"
    
    static let key_appModeOnStartup_option: String = "\(keyPrefix).appModeOnStartup.option"
    static let key_appModeOnStartup_modeName: String = "\(keyPrefix).appModeOnStartup.mode"
    
    static let key_layoutOnStartup_option: String = "\(keyPrefix).layoutOnStartup.option"
    static let key_layoutOnStartup_layoutName: String = "\(keyPrefix).layoutOnStartup.layout"
    
    func deleteAll() {
        
        userDefaults[Self.key_appModeOnStartup_option] = nil
        userDefaults[Self.key_appModeOnStartup_modeName] = nil
        
        userDefaults[Self.key_layoutOnStartup_option] = nil
        userDefaults[Self.key_layoutOnStartup_layoutName] = nil
    }
}
