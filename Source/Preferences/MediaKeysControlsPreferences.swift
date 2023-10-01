//
//  MediaKeysControlsPreferences.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all user preferences pertaining to the use of media keys with this application.
///
class MediaKeysControlsPreferences: PersistentPreferencesProtocol {
    
    var enabled: Bool
    var skipKeyBehavior: SkipKeyBehavior
    var repeatSpeed: SkipKeyRepeatSpeed
    
    private static let keyPrefix: String = "controls.mediaKeys"
    
    static let key_enabled: String = "\(keyPrefix).enabled"
    static let key_skipKeyBehavior: String = "\(keyPrefix).skipKeyBehavior"
    static let key_repeatSpeed: String = "\(keyPrefix).repeatSpeed"
    
    private typealias Defaults = PreferencesDefaults.Controls.MediaKeys
    
    required init(_ dict: [String: Any]) {
        
        enabled = dict[Self.key_enabled, Bool.self] ?? Defaults.enabled
        skipKeyBehavior = dict.enumValue(forKey: Self.key_skipKeyBehavior, ofType: SkipKeyBehavior.self) ?? Defaults.skipKeyBehavior
        repeatSpeed = dict.enumValue(forKey: Self.key_repeatSpeed, ofType: SkipKeyRepeatSpeed.self) ?? Defaults.repeatSpeed
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults[Self.key_enabled] = enabled
        defaults[Self.key_skipKeyBehavior] = skipKeyBehavior.rawValue
        defaults[Self.key_repeatSpeed] = repeatSpeed.rawValue
    }
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
