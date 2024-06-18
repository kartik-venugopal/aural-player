//
//  LegacyHistoryPreferences.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class LegacyHistoryPreferences {
    
    private static let keyPrefix: String = "history"
    
    static let key_recentlyAddedListSize: String = "\(keyPrefix).recentlyAddedListSize"
    static let key_recentlyPlayedListSize: String = "\(keyPrefix).recentlyPlayedListSize"
    
    func deleteAll() {
        
        userDefaults[Self.key_recentlyAddedListSize] = nil
        userDefaults[Self.key_recentlyPlayedListSize] = nil
    }
}
