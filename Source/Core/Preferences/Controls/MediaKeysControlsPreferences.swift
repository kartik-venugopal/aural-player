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
    
    private static let keyPrefix: String = "controls.mediaKeys"
    private typealias Defaults = PreferencesDefaults.Controls.MediaKeys
    
    lazy var enabled: UserPreference<Bool> = .init(defaultsKey: "\(Self.keyPrefix).enabled",
                                                                    defaultValue: Defaults.enabled)
    
    lazy var skipKeyBehavior: UserPreference<SkipKeyBehavior> = .init(defaultsKey: "\(Self.keyPrefix).skipKey.behavior",
                                                                    defaultValue: Defaults.skipKeyBehavior)
    
    lazy var skipKeyRepeatSpeed: UserPreference<SkipKeyRepeatSpeed> = .init(defaultsKey: "\(Self.keyPrefix).skipKey.repeatSpeed",
                                                                    defaultValue: Defaults.skipKeyRepeatSpeed)
    
    init(legacyPreferences: LegacyMediaKeysControlsPreferences? = nil) {
        
        guard let legacyPreferences = legacyPreferences else {return}
        
        if let skipKeyBehavior = legacyPreferences.skipKeyBehavior {
            self.skipKeyBehavior.value = skipKeyBehavior
        }
        
        if let repeatSpeed = legacyPreferences.repeatSpeed {
            self.skipKeyRepeatSpeed.value = repeatSpeed
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
}
