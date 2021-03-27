import Cocoa

class MetadataPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var btnEnableMusicBrainzCoverArtSearch: NSButton!
    
    @IBOutlet weak var btnEnableMusicBrainzOnDiskCoverArtCache: NSButton!
    @IBOutlet weak var btnDisableMusicBrainzOnDiskCoverArtCache: NSButton!
    
    override var nibName: String? {return "MetadataPreferences"}
    
    var preferencesView: NSView {
        return self.view
    }
    
    func resetFields(_ preferences: Preferences) {
        
        let musicBrainzPrefs = preferences.metadataPreferences.musicBrainz
       
        btnEnableMusicBrainzCoverArtSearch.onIf(musicBrainzPrefs.enableCoverArtSearch)
        
        btnEnableMusicBrainzOnDiskCoverArtCache.onIf(musicBrainzPrefs.enableOnDiskCoverArtCache)
//        btnDisableMusicBrainzOnDiskCoverArtCache.onIf(!metadataPrefs.musicBrainz.enableOnDiskCoverArtCache)
    }
    
    // Needed for radio button group
    @IBAction func musicBrainzOnDiskCacheCoverArtAction(_ sender: NSButton) {}
    
    func save(_ preferences: Preferences) throws {
        
        let prefs: MusicBrainzPreferences = preferences.metadataPreferences.musicBrainz
        
        prefs.enableCoverArtSearch = btnEnableMusicBrainzCoverArtSearch.isOn
        prefs.enableOnDiskCoverArtCache = btnEnableMusicBrainzOnDiskCoverArtCache.isOn
    }
}
