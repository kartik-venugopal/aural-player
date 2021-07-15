//
//  ControlsPreferences.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// Encapsulates all user preferences pertaining to usability (i.e. how the app is controlled).
///
class ControlsPreferences: PersistentPreferencesProtocol {
    
    var mediaKeys: MediaKeysControlsPreferences
    var gestures: GesturesControlsPreferences
    var remoteControl: RemoteControlPreferences
    
    internal required init(_ dict: [String: Any]) {
        
        mediaKeys = MediaKeysControlsPreferences(dict)
        gestures = GesturesControlsPreferences(dict)
        remoteControl = RemoteControlPreferences(dict)
    }
    
    func persist(to defaults: UserDefaults) {
        
        mediaKeys.persist(to: defaults)
        gestures.persist(to: defaults)
        remoteControl.persist(to: defaults)
    }
}
