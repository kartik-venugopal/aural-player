//
//  MetadataPreferences.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all user preferences pertaining to the retrieval of track metadata from the internet.
///
class MetadataPreferences {
    
    var musicBrainz: MusicBrainzPreferences
    var lastFM: LastFMPreferences
    
    // TODO: UserPreference<Int>
    var httpTimeout: Int = 5
    
    init() {
        
        musicBrainz = MusicBrainzPreferences()
        lastFM = LastFMPreferences()
    }
}
