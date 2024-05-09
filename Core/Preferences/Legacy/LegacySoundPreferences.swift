//
//  LegacySoundPreferences.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class LegacySoundPreferences {
    
    var timeDelta: Float?
    var rememberEffectsSettingsOption: LegacyRememberSettingsForTrackOptions?
    
    private static let keyPrefix: String = "sound"
    
    static let key_timeDelta: String = "\(keyPrefix).timeDelta"
    static let key_rememberEffectsSettingsOption: String = "\(keyPrefix).rememberEffectsSettings.option"
    
    internal required init(_ dict: [String: Any]) {
        
        timeDelta = dict.floatValue(forKey: Self.key_timeDelta)
        rememberEffectsSettingsOption = dict.enumValue(forKey: Self.key_rememberEffectsSettingsOption, ofType: LegacyRememberSettingsForTrackOptions.self)
    }
    
    func deleteAll() {
        
        userDefaults[Self.key_timeDelta] = nil
        userDefaults[Self.key_rememberEffectsSettingsOption] = nil
    }
}

enum LegacyRememberSettingsForTrackOptions: String, CaseIterable {
    
    case allTracks
    case individualTracks
}
