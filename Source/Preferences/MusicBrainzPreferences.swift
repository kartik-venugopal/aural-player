//
//  MusicBrainzPreferences.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Encapsulates all user preferences pertaining to the retrieval of track metadata
/// from the **MusicBrainz** online music database.
///
class MusicBrainzPreferences: PersistentPreferencesProtocol {

    var enableCoverArtSearch: Bool
    var enableOnDiskCoverArtCache: Bool
    
    private static let keyPrefix: String = "metadata.musicBrainz"
    
    static let key_enableCoverArtSearch: String = "\(keyPrefix).enableCoverArtSearch"
    static let key_enableOnDiskCoverArtCache: String = "\(keyPrefix).enableOnDiskCoverArtCache"
    
    private typealias Defaults = PreferencesDefaults.Metadata.MusicBrainz
    
    required init(_ dict: [String : Any]) {
        
        enableCoverArtSearch = dict[Self.key_enableCoverArtSearch, Bool.self] ?? Defaults.enableCoverArtSearch
        enableOnDiskCoverArtCache = dict[Self.key_enableOnDiskCoverArtCache, Bool.self] ?? Defaults.enableOnDiskCoverArtCache
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults[Self.key_enableCoverArtSearch] = enableCoverArtSearch
        defaults[Self.key_enableOnDiskCoverArtCache] = enableOnDiskCoverArtCache
    }
}
