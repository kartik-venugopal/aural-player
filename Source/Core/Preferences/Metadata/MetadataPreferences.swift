//
//  MetadataPreferences.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all user preferences pertaining to the retrieval of track metadata from the internet.
///
class MetadataPreferences {
    
    @UserPreference(key: "metadata.cacheTrackMetadata", defaultValue: Defaults.cacheTrackMetadata)
    var cacheTrackMetadata: Bool
    
    @UserPreference(key: "metadata.httpTimeout", defaultValue: Defaults.httpTimeout)
    var httpTimeout: Int
    
    let musicBrainz: MusicBrainzPreferences
    let lastFM: LastFMPreferences
    let lyrics: LyricsPreferences
    
    init() {
        
        musicBrainz = MusicBrainzPreferences()
        lastFM = LastFMPreferences()
        lyrics = LyricsPreferences()
    }
    
    ///
    /// An enumeration of default values for metadata retrieval preferences.
    ///
    fileprivate struct Defaults {
        
        static let cacheTrackMetadata: Bool = true
        static let httpTimeout: Int = 5
    }
}
