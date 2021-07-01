//
//  HistoryPreferences.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class HistoryPreferences: PersistentPreferencesProtocol {
    
    var recentlyAddedListSize: Int
    var recentlyPlayedListSize: Int
    
    private static let keyPrefix: String = "history"
    
    private static let key_recentlyAddedListSize: String = "\(keyPrefix).recentlyAddedListSize"
    private static let key_recentlyPlayedListSize: String = "\(keyPrefix).recentlyPlayedListSize"
    
    private typealias Defaults = PreferencesDefaults.History
    
    internal required init(_ dict: [String: Any]) {
        
        recentlyAddedListSize = dict.intValue(forKey: Self.key_recentlyAddedListSize) ?? Defaults.recentlyAddedListSize
        recentlyPlayedListSize = dict.intValue(forKey: Self.key_recentlyPlayedListSize) ?? Defaults.recentlyPlayedListSize
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults[Self.key_recentlyAddedListSize] = recentlyAddedListSize 
        defaults[Self.key_recentlyPlayedListSize] = recentlyPlayedListSize 
    }
}
