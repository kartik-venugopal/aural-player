import Foundation

class MetadataPreferences: PersistentPreferencesProtocol {
    
    var musicBrainz: MusicBrainzPreferences
    
    required init(_ defaults: [String : Any]) {
        musicBrainz = MusicBrainzPreferences(defaults)
    }
    
    func persist(to defaults: UserDefaults) {
        musicBrainz.persist(to: defaults)
    }
}

class MusicBrainzPreferences: PersistentPreferencesProtocol {

    var httpTimeout: Int
    var enableCoverArtSearch: Bool
    var enableOnDiskCoverArtCache: Bool
    
    private typealias Defaults = PreferencesDefaults.Metadata.MusicBrainz
    
    required init(_ defaults: [String : Any]) {
        
        httpTimeout = defaults["metadata.musicBrainz.httpTimeout", Int.self] ?? Defaults.httpTimeout
        
        enableCoverArtSearch = defaults["metadata.musicBrainz.enableCoverArtSearch", Bool.self] ?? Defaults.enableCoverArtSearch
        
        enableOnDiskCoverArtCache = defaults["metadata.musicBrainz.enableOnDiskCoverArtCache", Bool.self] ?? Defaults.enableOnDiskCoverArtCache
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults.setValue(httpTimeout, forKey: "metadata.musicBrainz.httpTimeout")
        defaults.setValue(enableCoverArtSearch, forKey: "metadata.musicBrainz.enableCoverArtSearch")
        defaults.setValue(enableOnDiskCoverArtCache, forKey: "metadata.musicBrainz.enableOnDiskCoverArtCache")
    }
}
