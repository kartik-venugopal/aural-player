//
//  MediaKeysControlsPreferences.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all user preferences pertaining to the use of media keys with this application.
///
class MediaKeysControlsPreferences {
    
    var enabled: Bool = true
    var skipKeyBehavior: SkipKeyBehavior = .hybrid
    var repeatSpeed: SkipKeyRepeatSpeed = .fast
    
    private static let keyPrefix: String = "controls.mediaKeys"
    
    static let key_enabled: String = "\(keyPrefix).enabled"
    static let key_skipKeyBehavior: String = "\(keyPrefix).skipKeyBehavior"
    static let key_repeatSpeed: String = "\(keyPrefix).repeatSpeed"
    
    private typealias Defaults = PreferencesDefaults.Controls.MediaKeys
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
