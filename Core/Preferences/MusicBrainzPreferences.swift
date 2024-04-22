//
//  MusicBrainzPreferences.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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

    var httpTimeout: Int = 5
    var enableCoverArtSearch: Bool = true
    var enableOnDiskCoverArtCache: Bool = true
    
    private static let keyPrefix: String = "metadata.musicBrainz"
    
    static let key_enableCoverArtSearch: String = "\(keyPrefix).enableCoverArtSearch"
    static let key_enableOnDiskCoverArtCache: String = "\(keyPrefix).enableOnDiskCoverArtCache"
    
    private typealias Defaults = PreferencesDefaults.Metadata.MusicBrainz
    
    init() {
    }
}
