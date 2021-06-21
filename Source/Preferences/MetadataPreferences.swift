import Foundation

class MetadataPreferences: PersistentPreferencesProtocol {
    
    var musicBrainz: MusicBrainzPreferences
    
    required init(_ defaultsDictionary: [String : Any]) {
        musicBrainz = MusicBrainzPreferences(defaultsDictionary)
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
    
    required init(_ defaultsDictionary: [String : Any]) {
        
        httpTimeout = defaultsDictionary["metadata.musicBrainz.httpTimeout", Int.self] ?? Defaults.httpTimeout
        
        enableCoverArtSearch = defaultsDictionary["metadata.musicBrainz.enableCoverArtSearch", Bool.self] ?? Defaults.enableCoverArtSearch
        
        enableOnDiskCoverArtCache = defaultsDictionary["metadata.musicBrainz.enableOnDiskCoverArtCache", Bool.self] ?? Defaults.enableOnDiskCoverArtCache
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults.setValue(httpTimeout, forKey: "metadata.musicBrainz.httpTimeout")
        defaults.setValue(enableCoverArtSearch, forKey: "metadata.musicBrainz.enableCoverArtSearch")
        defaults.setValue(enableOnDiskCoverArtCache, forKey: "metadata.musicBrainz.enableOnDiskCoverArtCache")
    }
}
