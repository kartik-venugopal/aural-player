//
//  LastFM_WSClient.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Cocoa

class LastFM_WSClient: LastFM_WSClientProtocol {
    
    static let webServicesBaseURL: String = "https://ws.audioscrobbler.com/2.0/"
    
    static let apiKey: String = "ba785720390959ec4080c9f86615f069"
    static let sharedSecret: String = "e5a700c076a1063a4d52edea30a38099"
    
    static let jsonDecoder: JSONDecoder = JSONDecoder()
    
    let httpClient: HTTPClient = .shared
    let cache: LastFMScrobbleCache
    
    private lazy var messenger: Messenger = .init(for: self)
    
    let retryOpQueue: OperationQueue = .init(opCount: 1, qos: .background)
    
    var lastFMPreferences: LastFMPreferences {
        preferences.metadataPreferences.lastFM
    }
    
    var sessionKey: String? {
        lastFMPreferences.sessionKey
    }
    
    var scrobblingEnabled: Bool {
        lastFMPreferences.enableScrobbling
    }
    
    var loveUnloveEnabled: Bool {
        lastFMPreferences.enableLoveUnlove
    }
    
    init(cache: LastFMScrobbleCache) {
        
        self.cache = cache
        
        messenger.subscribe(to: .Favorites.itemAdded, handler: favoriteAdded(favorite:))
        messenger.subscribe(to: .Favorites.itemsRemoved, handler: favoritesRemoved(favorites:))
    }
}
