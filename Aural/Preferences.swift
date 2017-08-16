/*
    Handles loading/saving of app user preferences
 */
import Foundation
import Cocoa

class Preferences {
    
    private static let singleton: Preferences = Preferences()
    
    private static let defaults: UserDefaults = UserDefaults.standard
    private static let defaultsDict: [String: Any] = defaults.dictionaryRepresentation()
    
    // Defaults values to use if saved preferences are unavailable
    
    // The (cached) user preferences. Values are held in these variables during app execution, and persisted upon exiting.
    var seekLength: Int
    var volumeDelta: Float
    var volumeOnStartup: VolumeStartupOptions
    var startupVolumeValue: Float
    var panDelta: Float
    var autoplayOnStartup: Bool
    var autoplayAfterAddingTracks: Bool
    var autoplayAfterAddingOption: AutoplayAfterAddingOptions
    
    var playlistOnStartup: PlaylistStartupOptions
    
    var viewOnStartup: ViewOnStartup
    var windowLocationOnStartup: WindowLocationOnStartup
    
    private init() {
        
        let prefs = Preferences.defaultsDict
        
        seekLength = prefs["seekLength"] as? Int ?? PreferencesDefaults.seekLength
        volumeDelta = prefs["volumeDelta"] as? Float ?? PreferencesDefaults.volumeDelta
        
        if let volumeOnStartupStr = prefs["volumeOnStartup"] as? String {
            volumeOnStartup = VolumeStartupOptions(rawValue: volumeOnStartupStr)!
        } else {
            volumeOnStartup = PreferencesDefaults.volumeOnStartup
        }
        
        startupVolumeValue = prefs["startupVolumeValue"] as? Float ?? PreferencesDefaults.startupVolumeValue
        
        panDelta = prefs["panDelta"] as? Float ?? PreferencesDefaults.panDelta
        autoplayOnStartup = prefs["autoplayOnStartup"] as? Bool ?? PreferencesDefaults.autoplayOnStartup
        autoplayAfterAddingTracks = prefs["autoplayAfterAddingTracks"] as? Bool ?? PreferencesDefaults.autoplayAfterAddingTracks
        
        if let autoplayAfterAddingOptionStr = prefs["autoplayAfterAddingTracks.option"] as? String {
            autoplayAfterAddingOption = AutoplayAfterAddingOptions(rawValue: autoplayAfterAddingOptionStr)!
        } else {
            autoplayAfterAddingOption = PreferencesDefaults.autoplayAfterAddingOption
        }
        
        if let playlistOnStartupStr = prefs["playlistOnStartup"] as? String {
            playlistOnStartup = PlaylistStartupOptions(rawValue: playlistOnStartupStr)!
        } else {
            playlistOnStartup = PreferencesDefaults.playlistOnStartup
        }
        
        viewOnStartup = PreferencesDefaults.viewOnStartup
        
        if let viewOnStartupOptionStr = prefs["viewOnStartup.option"] as? String {
            viewOnStartup.option = ViewStartupOptions(rawValue: viewOnStartupOptionStr)!
        }
        
        if let viewTypeStr = prefs["viewOnStartup.viewType"] as? String {
            viewOnStartup.viewType = ViewTypes(rawValue: viewTypeStr)!
        }
        
        windowLocationOnStartup = PreferencesDefaults.windowLocationOnStartup
        
        if let windowLocationOnStartupOptionStr = prefs["windowLocationOnStartup.option"] as? String {
            windowLocationOnStartup.option = WindowLocationOptions(rawValue: windowLocationOnStartupOptionStr)!
        }
        
        if let windowLocationStr = prefs["windowLocationOnStartup.location"] as? String {
            windowLocationOnStartup.windowLocation = WindowLocations(rawValue: windowLocationStr)!
        }
    }
    
    static func instance() -> Preferences {
        return singleton
    }
    
    // Saves the preferences to disk (copies the values from the cache to UserDefaults)
    static func persist() {
        
        defaults.set(singleton.seekLength, forKey: "seekLength")
        defaults.set(singleton.volumeDelta, forKey: "volumeDelta")
        defaults.set(singleton.volumeOnStartup.rawValue, forKey: "volumeOnStartup")
        defaults.set(singleton.startupVolumeValue, forKey: "startupVolumeValue")
        
        defaults.set(singleton.panDelta, forKey: "panDelta")
        defaults.set(singleton.autoplayOnStartup, forKey: "autoplayOnStartup")
        defaults.set(singleton.autoplayAfterAddingTracks, forKey: "autoplayAfterAddingTracks")
        defaults.set(singleton.autoplayAfterAddingOption.rawValue, forKey: "autoplayAfterAddingTracks.option")
        
        defaults.set(singleton.playlistOnStartup.rawValue, forKey: "playlistOnStartup")
        
        defaults.set(singleton.viewOnStartup.option.rawValue, forKey: "viewOnStartup.option")
        defaults.set(singleton.viewOnStartup.viewType.rawValue, forKey: "viewOnStartup.viewType")
        
        defaults.set(singleton.windowLocationOnStartup.option.rawValue, forKey: "windowLocationOnStartup.option")
        defaults.set(singleton.windowLocationOnStartup.windowLocation.rawValue, forKey: "windowLocationOnStartup.location")
    }
    
    // Persists without blocking the calling thread
    static func persistAsync() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            persist()
        }
    }
}

/*
    Container for default values for user preferences
 */
class PreferencesDefaults {
    
    // Player prefs
    static let seekLength: Int = 5
    static let volumeDelta: Float = 0.05
    static let volumeOnStartup: VolumeStartupOptions = .rememberFromLastAppLaunch
    static let startupVolumeValue: Float = 0.5
    static let panDelta: Float = 0.1
    static let autoplayOnStartup: Bool = false
    static let autoplayAfterAddingTracks: Bool = false
    static let autoplayAfterAddingOption: AutoplayAfterAddingOptions = .ifNotPlaying
    
    // Playlist prefs
    static let playlistOnStartup: PlaylistStartupOptions = .rememberFromLastAppLaunch
    
    // View prefs
    static let viewOnStartup: ViewOnStartup = ViewOnStartup.defaultInstance
    static let windowLocationOnStartup: WindowLocationOnStartup = WindowLocationOnStartup.defaultInstance
}
