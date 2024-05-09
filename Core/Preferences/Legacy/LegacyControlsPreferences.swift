//
//  LegacyControlsPreferences.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class LegacyControlsPreferences {
    
    var mediaKeys: LegacyMediaKeysControlsPreferences
//    var gestures: LegacyGesturesControlsPreferences
//    var remoteControl: LegacyRemoteControlPreferences
    
    internal required init(_ dict: [String: Any]) {
        
        mediaKeys = LegacyMediaKeysControlsPreferences(dict)
//        gestures = LegacyGesturesControlsPreferences(dict)
//        remoteControl = LegacyRemoteControlPreferences(dict)
    }
}
