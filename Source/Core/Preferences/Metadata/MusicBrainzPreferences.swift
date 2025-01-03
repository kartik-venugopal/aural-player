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

    lazy var enableCoverArtSearch: UserPreference<Bool> = .init(defaultsKey: "\(Self.keyPrefix).enableCoverArtSearch", defaultValue: Defaults.enableCoverArtSearch)
    lazy var enableOnDiskCoverArtCache: UserPreference<Bool> = .init(defaultsKey: "\(Self.keyPrefix).enableOnDiskCoverArtCache", defaultValue: Defaults.enableOnDiskCoverArtCache)
    
    var cachingEnabled: Bool {
        enableCoverArtSearch.value && enableOnDiskCoverArtCache.value
    }
    
    private static let keyPrefix: String = "metadata.musicBrainz"
    private typealias Defaults = PreferencesDefaults.Metadata.MusicBrainz
}
