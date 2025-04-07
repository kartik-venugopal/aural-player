//
//  MediaKeysControlsPreferences.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all user preferences pertaining to the use of media keys with this application.
///
class MediaKeysControlsPreferences {
    
    @UserPreference(key: "controls.mediaKeys.enabled", defaultValue: Defaults.enabled)
    var enabled: Bool
    
    @EnumUserPreference(key: "controls.mediaKeys.skipKey.behavior", defaultValue: Defaults.skipKeyBehavior)
    var skipKeyBehavior: SkipKeyBehavior
    
    @EnumUserPreference(key: "controls.mediaKeys.skipKey.repeatSpeed", defaultValue: Defaults.skipKeyRepeatSpeed)
    var skipKeyRepeatSpeed: SkipKeyRepeatSpeed
    
    init(legacyPreferences: LegacyMediaKeysControlsPreferences? = nil) {
        
        guard let legacyPreferences = legacyPreferences else {return}
        
        if let skipKeyBehavior = legacyPreferences.skipKeyBehavior {
            self.skipKeyBehavior = skipKeyBehavior
        }
        
        if let repeatSpeed = legacyPreferences.repeatSpeed {
            self.skipKeyRepeatSpeed = repeatSpeed
        }
        
        legacyPreferences.deleteAll()
    }
    
    enum SkipKeyBehavior: String, CaseIterable {
        
        case hybrid
        case trackChangesOnly
        case seekingOnly
    }

    enum SkipKeyRepeatSpeed: String, CaseIterable {
        
        case slow
        case medium
        case fast
    }
    
    ///
    /// An enumeration of default values for media keys preferences.
    ///
    fileprivate struct Defaults {
        
        static let enabled: Bool = true
        static let skipKeyBehavior: SkipKeyBehavior = .hybrid
        static let skipKeyRepeatSpeed: SkipKeyRepeatSpeed = .medium
    }
}
