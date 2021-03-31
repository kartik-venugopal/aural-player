import Cocoa

class MetadataPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var btnEnableMusicBrainzCoverArtSearch: NSButton!
    
    @IBOutlet weak var btnEnableMusicBrainzOnDiskCoverArtCache: NSButton!
    @IBOutlet weak var btnDisableMusicBrainzOnDiskCoverArtCache: NSButton!
    
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    private let trackReader: TrackReader = ObjectGraph.trackReader
    private let musicBrainzCache: MusicBrainzCache = ObjectGraph.musicBrainzCache
    
    override var nibName: String? {return "MetadataPreferences"}
    
    var preferencesView: NSView {
        return self.view
    }
    
    func resetFields(_ preferences: Preferences) {
        
        let musicBrainzPrefs = preferences.metadataPreferences.musicBrainz
       
        btnEnableMusicBrainzCoverArtSearch.onIf(musicBrainzPrefs.enableCoverArtSearch)
        
        if musicBrainzPrefs.enableOnDiskCoverArtCache {
            btnEnableMusicBrainzOnDiskCoverArtCache.on()
        } else {
            btnDisableMusicBrainzOnDiskCoverArtCache.on()
        }
    }
    
    // Needed for radio button group
    @IBAction func musicBrainzOnDiskCacheCoverArtAction(_ sender: NSButton) {}
    
    func save(_ preferences: Preferences) throws {
        
        let prefs: MusicBrainzPreferences = preferences.metadataPreferences.musicBrainz
        
        let wasSearchDisabled: Bool = !prefs.enableCoverArtSearch
        
        prefs.enableCoverArtSearch = btnEnableMusicBrainzCoverArtSearch.isOn
        prefs.enableOnDiskCoverArtCache = btnEnableMusicBrainzOnDiskCoverArtCache.isOn
        
        if wasSearchDisabled && prefs.enableCoverArtSearch, let playingTrack = playbackInfo.playingTrack {
            trackReader.loadArtAsync(for: playingTrack, immediate: true)
        }
        
        if prefs.enableCoverArtSearch && prefs.enableOnDiskCoverArtCache {
            
            musicBrainzCache.onDiskCachingEnabled()
            
        } else {
            
            musicBrainzCache.onDiskCachingDisabled()
        }
    }
}
