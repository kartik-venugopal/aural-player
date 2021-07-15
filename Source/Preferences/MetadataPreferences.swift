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

///
/// Encapsulates all user preferences pertaining to the retrieval of track metadata from the internet.
///
class MetadataPreferences: PersistentPreferencesProtocol {
    
    var musicBrainz: MusicBrainzPreferences
    
    required init(_ dict: [String : Any]) {
        musicBrainz = MusicBrainzPreferences(dict)
    }
    
    func persist(to defaults: UserDefaults) {
        musicBrainz.persist(to: defaults)
    }
}
