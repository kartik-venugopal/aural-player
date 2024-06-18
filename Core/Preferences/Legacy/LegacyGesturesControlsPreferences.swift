//
//  LegacyGesturesControlsPreferences.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class LegacyGesturesControlsPreferences {
    
    var allowPlaylistNavigation: Bool?
    
    private static let keyPrefix: String = "controls.gestures"
    
    static let key_allowPlaylistNavigation: String = "\(keyPrefix).allowPlaylistNavigation"
    static let key_allowPlaylistTabToggle: String = "\(keyPrefix).allowPlaylistTabToggle"
    
    internal required init(_ dict: [String: Any]) {
        allowPlaylistNavigation = dict[Self.key_allowPlaylistNavigation, Bool.self]
    }
    
    func deleteAll() {

        userDefaults[Self.key_allowPlaylistNavigation] = nil
        userDefaults[Self.key_allowPlaylistTabToggle] = nil
    }
}
