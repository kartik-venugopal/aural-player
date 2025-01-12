//
//  LegacyMediaKeysControlsPreferences.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class LegacyMediaKeysControlsPreferences {
    
    var skipKeyBehavior: MediaKeysControlsPreferences.SkipKeyBehavior?
    var repeatSpeed: MediaKeysControlsPreferences.SkipKeyRepeatSpeed?
    
    private static let keyPrefix: String = "controls.mediaKeys"
    
    static let key_skipKeyBehavior: String = "\(keyPrefix).skipKeyBehavior"
    static let key_repeatSpeed: String = "\(keyPrefix).repeatSpeed"
    
    required init(_ dict: [String: Any]) {
        
        skipKeyBehavior = dict.enumValue(forKey: Self.key_skipKeyBehavior, ofType: MediaKeysControlsPreferences.SkipKeyBehavior.self)
        repeatSpeed = dict.enumValue(forKey: Self.key_repeatSpeed, ofType: MediaKeysControlsPreferences.SkipKeyRepeatSpeed.self)
    }
    
    func deleteAll() {
        
        userDefaults[Self.key_skipKeyBehavior] = nil
        userDefaults[Self.key_repeatSpeed] = nil
    }
}
