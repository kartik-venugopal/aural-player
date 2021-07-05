//
//  MetadataPreferences.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class MetadataPreferences: PersistentPreferencesProtocol {
    
    var musicBrainz: MusicBrainzPreferences
    
    required init(_ dict: [String : Any]) {
        musicBrainz = MusicBrainzPreferences(dict)
    }
    
    func persist(to defaults: UserDefaults) {
        musicBrainz.persist(to: defaults)
    }
}

class MusicBrainzPreferences: PersistentPreferencesProtocol {

    var httpTimeout: Int
    var enableCoverArtSearch: Bool
    var enableOnDiskCoverArtCache: Bool
    
    private static let keyPrefix: String = "metadata.musicBrainz"
    
    static let key_httpTimeout: String = "\(keyPrefix).httpTimeout"
    static let key_enableCoverArtSearch: String = "\(keyPrefix).enableCoverArtSearch"
    static let key_enableOnDiskCoverArtCache: String = "\(keyPrefix).enableOnDiskCoverArtCache"
    
    private typealias Defaults = PreferencesDefaults.Metadata.MusicBrainz
    
    required init(_ dict: [String : Any]) {
        
        httpTimeout = dict.intValue(forKey: Self.key_httpTimeout) ?? Defaults.httpTimeout
        
        enableCoverArtSearch = dict[Self.key_enableCoverArtSearch, Bool.self] ?? Defaults.enableCoverArtSearch
        
        enableOnDiskCoverArtCache = dict[Self.key_enableOnDiskCoverArtCache, Bool.self] ?? Defaults.enableOnDiskCoverArtCache
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults[Self.key_httpTimeout] = httpTimeout
        defaults[Self.key_enableCoverArtSearch] = enableCoverArtSearch
        defaults[Self.key_enableOnDiskCoverArtCache] = enableOnDiskCoverArtCache
    }
}
