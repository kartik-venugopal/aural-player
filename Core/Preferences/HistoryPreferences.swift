//
//  HistoryPreferences.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all user preferences pertaining to the track history lists.
///
class HistoryPreferences {
    
    var recentlyAddedListSize: Int = 25
    var recentlyPlayedListSize: Int = 25
    
    private static let keyPrefix: String = "history"
    
    static let key_recentlyAddedListSize: String = "\(keyPrefix).recentlyAddedListSize"
    static let key_recentlyPlayedListSize: String = "\(keyPrefix).recentlyPlayedListSize"
    
    private typealias Defaults = PreferencesDefaults.History
    
    init() {
    }
}
