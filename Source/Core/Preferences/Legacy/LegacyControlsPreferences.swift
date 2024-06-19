//
//  LegacyControlsPreferences.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class LegacyControlsPreferences {
    
    var mediaKeys: LegacyMediaKeysControlsPreferences
    var gestures: LegacyGesturesControlsPreferences
    
    internal required init(_ dict: [String: Any]) {
        
        mediaKeys = LegacyMediaKeysControlsPreferences(dict)
        gestures = LegacyGesturesControlsPreferences(dict)
    }
}
