//
//  ControlsPreferences.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all user preferences pertaining to usability (i.e. how the app is controlled).
///
class ControlsPreferences {
    
    var mediaKeys: MediaKeysControlsPreferences
    var gestures: GesturesControlsPreferences
    var remoteControl: RemoteControlPreferences
    
    init(legacyPreferences: LegacyControlsPreferences? = nil) {
        
        mediaKeys = MediaKeysControlsPreferences(legacyPreferences: legacyPreferences?.mediaKeys)
        gestures = GesturesControlsPreferences(legacyPreferences: legacyPreferences?.gestures)
        remoteControl = RemoteControlPreferences()
    }
}
