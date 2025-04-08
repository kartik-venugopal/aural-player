//
//  MusicBrainzPreferences.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Encapsulates all user preferences pertaining to the retrieval of track metadata
/// from the **MusicBrainz** online music database.
///
class MusicBrainzPreferences {

    @UserPreference(key: "metadata.musicBrainz.enableCoverArtSearch", defaultValue: Defaults.enableCoverArtSearch)
    var enableCoverArtSearch: Bool
    
    @UserPreference(key: "metadata.musicBrainz.enableOnDiskCoverArtCache", defaultValue: Defaults.enableOnDiskCoverArtCache)
    var enableOnDiskCoverArtCache: Bool
    
    var cachingEnabled: Bool {
        enableCoverArtSearch && enableOnDiskCoverArtCache
    }
    
    ///
    /// An enumeration of default values for **MusicBrainz** metadata retrieval preferences.
    ///
    fileprivate struct Defaults {
        
        static let enableCoverArtSearch: Bool = true
        static let enableOnDiskCoverArtCache: Bool = true
    }
}
