import Foundation

class MetadataPreferences: PersistentPreferencesProtocol {
    
    var musicBrainz: MusicBrainzPreferences
    
    required init(_ defaultsDictionary: [String : Any]) {
        musicBrainz = MusicBrainzPreferences(defaultsDictionary)
    }
    
    func persist(defaults: UserDefaults) {
        musicBrainz.persist(defaults: defaults)
    }
}

class MusicBrainzPreferences: PersistentPreferencesProtocol {

    var httpTimeout: Int
    var enableCoverArtSearch: Bool
    var enableOnDiskCoverArtCache: Bool
    
    required init(_ defaultsDictionary: [String : Any]) {
        
        httpTimeout = (defaultsDictionary["metadata.musicBrainz.httpTimeout"] as? NSNumber)?.intValue ?? PreferencesDefaults.Metadata.MusicBrainz.httpTimeout
        
        enableCoverArtSearch = defaultsDictionary["metadata.musicBrainz.enableCoverArtSearch"] as? Bool ?? PreferencesDefaults.Metadata.MusicBrainz.enableCoverArtSearch
        
        enableOnDiskCoverArtCache = defaultsDictionary["metadata.musicBrainz.enableOnDiskCoverArtCache"] as? Bool ?? PreferencesDefaults.Metadata.MusicBrainz.enableOnDiskCoverArtCache
    }
    
    func persist(defaults: UserDefaults) {
        
        defaults.setValue(httpTimeout, forKey: "metadata.musicBrainz.httpTimeout")
        defaults.setValue(enableCoverArtSearch, forKey: "metadata.musicBrainz.enableCoverArtSearch")
        defaults.setValue(enableOnDiskCoverArtCache, forKey: "metadata.musicBrainz.enableOnDiskCoverArtCache")
    }
}
