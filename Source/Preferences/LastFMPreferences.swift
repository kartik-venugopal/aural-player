//
//  LastFMPreferences.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class LastFMPreferences: PersistentPreferencesProtocol {
    
    var sessionKey: String?
    var hasSessionKey: Bool {
        sessionKey != nil
    }
    
    var enableScrobbling: Bool
    var enableLoveUnlove: Bool
    
//    var enableCoverArtSearch: Bool
//    var enableOnDiskCoverArtCache: Bool
    
    private static let keyPrefix: String = "metadata.lastFM"
    
    static let key_sessionKey: String = "\(keyPrefix).sessionKey"
    
    static let key_enableScrobbling: String = "\(keyPrefix).enableScrobbling"
    static let key_enableLoveUnlove: String = "\(keyPrefix).enableLoveUnlove"
    
//    static let key_enableCoverArtSearch: String = "\(keyPrefix).enableCoverArtSearch"
//    static let key_enableOnDiskCoverArtCache: String = "\(keyPrefix).enableOnDiskCoverArtCache"
    
    private typealias Defaults = PreferencesDefaults.Metadata.LastFM
    
    required init(_ dict: [String : Any]) {
        
        sessionKey = dict[Self.key_sessionKey, String.self]
        
        enableScrobbling = dict[Self.key_enableScrobbling, Bool.self] ?? Defaults.enableScrobbling
        enableLoveUnlove = dict[Self.key_enableLoveUnlove, Bool.self] ?? Defaults.enableLoveUnlove
        
        //        enableCoverArtSearch = dict[Self.key_enableCoverArtSearch, Bool.self] ?? Defaults.enableCoverArtSearch
        //        enableOnDiskCoverArtCache = dict[Self.key_enableOnDiskCoverArtCache, Bool.self] ?? Defaults.enableOnDiskCoverArtCache
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults[Self.key_sessionKey] = sessionKey
        
        defaults[Self.key_enableScrobbling] = enableScrobbling
        defaults[Self.key_enableLoveUnlove] = enableLoveUnlove
        
//        defaults[Self.key_enableCoverArtSearch] = enableCoverArtSearch
//        defaults[Self.key_enableOnDiskCoverArtCache] = enableOnDiskCoverArtCache
    }
    
    func persistSessionKey(to defaults: UserDefaults) {
        defaults[Self.key_sessionKey] = sessionKey
    }
}
