//
//  LegacyPlaybackPreferences.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class LegacyPlaybackPreferences {
    
    var rememberLastPositionOption: LegacyRememberSettingsForTrackOptions?
    
    private static let keyPrefix: String = "playback"
    static let key_rememberLastPositionOption: String = "\(keyPrefix).rememberLastPosition.option"
    
    internal required init(_ dict: [String: Any]) {
        
        rememberLastPositionOption = dict.enumValue(forKey: Self.key_rememberLastPositionOption,
                                                    ofType: LegacyRememberSettingsForTrackOptions.self)
    }
    
    func deleteAll() {
        userDefaults[Self.key_rememberLastPositionOption] = nil
    }
}
