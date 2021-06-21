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
    
    private static let key_httpTimeout: String = "\(keyPrefix).httpTimeout"
    private static let key_enableCoverArtSearch: String = "\(keyPrefix).enableCoverArtSearch"
    private static let key_enableOnDiskCoverArtCache: String = "\(keyPrefix).enableOnDiskCoverArtCache"
    
    private typealias Defaults = PreferencesDefaults.Metadata.MusicBrainz
    
    required init(_ dict: [String : Any]) {
        
        httpTimeout = dict[Self.key_httpTimeout, Int.self] ?? Defaults.httpTimeout
        
        enableCoverArtSearch = dict[Self.key_enableCoverArtSearch, Bool.self] ?? Defaults.enableCoverArtSearch
        
        enableOnDiskCoverArtCache = dict[Self.key_enableOnDiskCoverArtCache, Bool.self] ?? Defaults.enableOnDiskCoverArtCache
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults.setValue(httpTimeout, forKey: Self.key_httpTimeout)
        defaults.setValue(enableCoverArtSearch, forKey: Self.key_enableCoverArtSearch)
        defaults.setValue(enableOnDiskCoverArtCache, forKey: Self.key_enableOnDiskCoverArtCache)
    }
}
