//
//  MetadataPreferences.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all user preferences pertaining to the retrieval of track metadata from the internet.
///
class MetadataPreferences: PersistentPreferencesProtocol {
    
    var musicBrainz: MusicBrainzPreferences
    var lastFM: LastFMPreferences
    
    var httpTimeout: Int
    
    private static let keyPrefix: String = "metadata"
    static let key_httpTimeout: String = "\(keyPrefix).httpTimeout"
    
    required init(_ dict: [String : Any]) {
        
        httpTimeout = dict.intValue(forKey: Self.key_httpTimeout) ?? PreferencesDefaults.Metadata.httpTimeout
        
        musicBrainz = MusicBrainzPreferences(dict)
        lastFM = LastFMPreferences(dict)
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults[Self.key_httpTimeout] = httpTimeout
        
        musicBrainz.persist(to: defaults)
        lastFM.persist(to: defaults)
    }
}
