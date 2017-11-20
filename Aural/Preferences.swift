/*
    Handles loading/saving of app user preferences
 */
import Foundation
import Cocoa

// Contract for a persistent preferences object
fileprivate protocol PersistentPreferencesProtocol {
    
    init(_ defaultsDictionary: [String: Any])
    
    func persist(defaults: UserDefaults)
}

class Preferences: PersistentPreferencesProtocol {
    
    private static let singleton: Preferences = Preferences(Preferences.defaultsDict)
    
    fileprivate static let defaults: UserDefaults = UserDefaults.standard
    fileprivate static let defaultsDict: [String: Any] = defaults.dictionaryRepresentation()
    
    // The (cached) user preferences. Values are held in these variables during app execution, and persisted prior to exiting.
    
    var playbackPreferences: PlaybackPreferences
    var soundPreferences: SoundPreferences
    var playlistPreferences: PlaylistPreferences
    var viewPreferences: ViewPreferences
    var historyPreferences: HistoryPreferences
    var controlsPreferences: ControlsPreferences
    
    private var allPreferences: [PersistentPreferencesProtocol] = []
    
    internal required init(_ defaultsDictionary: [String: Any]) {
        
        controlsPreferences = ControlsPreferences(defaultsDictionary)
        playbackPreferences = PlaybackPreferences(defaultsDictionary, controlsPreferences)
        soundPreferences = SoundPreferences(defaultsDictionary, controlsPreferences)
        
        playlistPreferences = PlaylistPreferences(defaultsDictionary)
        viewPreferences = ViewPreferences(defaultsDictionary)
        historyPreferences = HistoryPreferences(defaultsDictionary)
        
        allPreferences = [playbackPreferences, soundPreferences, playlistPreferences, viewPreferences, historyPreferences, controlsPreferences]
    }
    
    func persist(defaults: UserDefaults) {
        allPreferences.forEach({$0.persist(defaults: defaults)})
    }
    
    static func instance() -> Preferences {
        return singleton
    }
    
    // Saves the preferences to disk (copies the values from the cache to UserDefaults)
    static func persist(_ preferences: Preferences) {
        preferences.persist(defaults: defaults)
    }
}

class PlaybackPreferences: PersistentPreferencesProtocol {
    
    var seekLength: Int
    
    private let scrollSensitiveSeekLengths: [ScrollSensitivity: Double] = [.low: 2.5, .medium: 5, .high: 10]
    var seekLength_continuous: Double {
        return scrollSensitiveSeekLengths[controlsPreferences.seekSensitivity]!
    }
    
    private var controlsPreferences: ControlsPreferences!
    
    var autoplayOnStartup: Bool
    var autoplayAfterAddingTracks: Bool
    var autoplayAfterAddingOption: AutoplayAfterAddingOptions
    
    fileprivate convenience init(_ defaultsDictionary: [String: Any], _ controlsPreferences: ControlsPreferences) {
        self.init(defaultsDictionary)
        self.controlsPreferences = controlsPreferences
    }
    
    internal required init(_ defaultsDictionary: [String: Any]) {
    
        seekLength = defaultsDictionary["playback.seekLength"] as? Int ?? PreferencesDefaults.Playback.seekLength
        
        autoplayOnStartup = defaultsDictionary["playback.autoplayOnStartup"] as? Bool ?? PreferencesDefaults.Playback.autoplayOnStartup
        
        autoplayAfterAddingTracks = defaultsDictionary["playback.autoplayAfterAddingTracks"] as? Bool ?? PreferencesDefaults.Playback.autoplayAfterAddingTracks
        
        if let autoplayAfterAddingOptionStr = defaultsDictionary["playback.autoplayAfterAddingTracks.option"] as? String {
            autoplayAfterAddingOption = AutoplayAfterAddingOptions(rawValue: autoplayAfterAddingOptionStr)!
        } else {
            autoplayAfterAddingOption = PreferencesDefaults.Playback.autoplayAfterAddingOption
        }
    }
    
    func persist(defaults: UserDefaults) {
        
        defaults.set(seekLength, forKey: "playback.seekLength")
        
        defaults.set(autoplayOnStartup, forKey: "playback.autoplayOnStartup")
        defaults.set(autoplayAfterAddingTracks, forKey: "playback.autoplayAfterAddingTracks")
        defaults.set(autoplayAfterAddingOption.rawValue, forKey: "playback.autoplayAfterAddingTracks.option")

    }
}

class SoundPreferences: PersistentPreferencesProtocol {
    
    var volumeDelta: Float
    
    private let scrollSensitiveVolumeDeltas: [ScrollSensitivity: Float] = [.low: 0.025, .medium: 0.05, .high: 0.1]
    var volumeDelta_continuous: Float {
        return scrollSensitiveVolumeDeltas[controlsPreferences.volumeControlSensitivity]!
    }
    
    var volumeOnStartup: VolumeStartupOptions
    var startupVolumeValue: Float
    var panDelta: Float
    
    private var controlsPreferences: ControlsPreferences!
    
    fileprivate convenience init(_ defaultsDictionary: [String: Any], _ controlsPreferences: ControlsPreferences) {
        self.init(defaultsDictionary)
        self.controlsPreferences = controlsPreferences
    }
    
    internal required init(_ defaultsDictionary: [String: Any]) {
        
        let defaultsDictionary = Preferences.defaultsDict
        
        volumeDelta = defaultsDictionary["sound.volumeDelta"] as? Float ?? PreferencesDefaults.Sound.volumeDelta
        
        if let volumeOnStartupStr = defaultsDictionary["sound.volumeOnStartup"] as? String {
            volumeOnStartup = VolumeStartupOptions(rawValue: volumeOnStartupStr)!
        } else {
            volumeOnStartup = PreferencesDefaults.Sound.volumeOnStartup
        }
        
        startupVolumeValue = defaultsDictionary["sound.startupVolumeValue"] as? Float ?? PreferencesDefaults.Sound.startupVolumeValue
        
        panDelta = defaultsDictionary["sound.panDelta"] as? Float ?? PreferencesDefaults.Sound.panDelta
    }
    
    func persist(defaults: UserDefaults) {
        
        
        defaults.set(volumeDelta, forKey: "sound.volumeDelta")
        
        defaults.set(volumeOnStartup.rawValue, forKey: "sound.volumeOnStartup")
        defaults.set(startupVolumeValue, forKey: "sound.startupVolumeValue")
        
        defaults.set(panDelta, forKey: "sound.panDelta")
    }
}

class PlaylistPreferences: PersistentPreferencesProtocol {
    
    var playlistOnStartup: PlaylistStartupOptions
    
    internal required init(_ defaultsDictionary: [String: Any]) {
        
        if let playlistOnStartupStr = defaultsDictionary["playlist.playlistOnStartup"] as? String {
            playlistOnStartup = PlaylistStartupOptions(rawValue: playlistOnStartupStr)!
        } else {
            playlistOnStartup = PreferencesDefaults.Playlist.playlistOnStartup
        }
    }
    
    func persist(defaults: UserDefaults) {
        defaults.set(playlistOnStartup.rawValue, forKey: "playlist.playlistOnStartup")
    }
}

class ViewPreferences: PersistentPreferencesProtocol {
 
    var viewOnStartup: ViewOnStartup
    var windowLocationOnStartup: WindowLocationOnStartup
    var playlistLocationOnStartup: PlaylistLocationOnStartup
    
    internal required init(_ defaultsDictionary: [String: Any]) {
        
        viewOnStartup = PreferencesDefaults.View.viewOnStartup
        
        if let viewOnStartupOptionStr = defaultsDictionary["view.viewOnStartup.option"] as? String {
            viewOnStartup.option = ViewStartupOptions(rawValue: viewOnStartupOptionStr)!
        }
        
        if let viewTypeStr = defaultsDictionary["view.viewOnStartup.viewType"] as? String {
            viewOnStartup.viewType = ViewTypes(rawValue: viewTypeStr)!
        }
        
        windowLocationOnStartup = PreferencesDefaults.View.windowLocationOnStartup
        
        if let windowLocationOnStartupOptionStr = defaultsDictionary["view.windowLocationOnStartup.option"] as? String {
            windowLocationOnStartup.option = WindowLocationOptions(rawValue: windowLocationOnStartupOptionStr)!
        }
        
        if let windowLocationStr = defaultsDictionary["view.windowLocationOnStartup.location"] as? String {
            windowLocationOnStartup.windowLocation = WindowLocations(rawValue: windowLocationStr)!
        }
        
        playlistLocationOnStartup = PreferencesDefaults.View.playlistLocationOnStartup
        
        if let playlistLocationOnStartupOptionStr = defaultsDictionary["view.playlistLocationOnStartup.option"] as? String {
            playlistLocationOnStartup.option = PlaylistLocationOptions(rawValue: playlistLocationOnStartupOptionStr)!
        }
        
        if let playlistLocationStr = defaultsDictionary["view.playlistLocationOnStartup.location"] as? String {
            playlistLocationOnStartup.playlistLocation = PlaylistLocations(rawValue: playlistLocationStr)!
        }
    }
    
    func persist(defaults: UserDefaults) {
        
        defaults.set(viewOnStartup.option.rawValue, forKey: "view.viewOnStartup.option")
        defaults.set(viewOnStartup.viewType.rawValue, forKey: "view.viewOnStartup.viewType")
        
        defaults.set(windowLocationOnStartup.option.rawValue, forKey: "view.windowLocationOnStartup.option")
        defaults.set(windowLocationOnStartup.windowLocation.rawValue, forKey: "view.windowLocationOnStartup.location")
        
        defaults.set(playlistLocationOnStartup.option.rawValue, forKey: "view.playlistLocationOnStartup.option")
        defaults.set(playlistLocationOnStartup.playlistLocation.rawValue, forKey: "view.playlistLocationOnStartup.location")
    }
}

class HistoryPreferences: PersistentPreferencesProtocol {
    
    var recentlyAddedListSize: Int
    var recentlyPlayedListSize: Int
    var favoritesListSize: Int
    
    internal required init(_ defaultsDictionary: [String: Any]) {
        
        let defaultsDictionary = Preferences.defaultsDict
        
        recentlyAddedListSize = defaultsDictionary["history.recentlyAddedListSize"] as? Int ?? PreferencesDefaults.History.recentlyAddedListSize
        recentlyPlayedListSize = defaultsDictionary["history.recentlyPlayedListSize"] as? Int ?? PreferencesDefaults.History.recentlyPlayedListSize
        favoritesListSize = defaultsDictionary["history.favoritesListSize"] as? Int ?? PreferencesDefaults.History.favoritesListSize
    }
    
    func persist(defaults: UserDefaults) {
        
        defaults.set(recentlyAddedListSize, forKey: "history.recentlyAddedListSize")
        defaults.set(recentlyPlayedListSize, forKey: "history.recentlyPlayedListSize")
        defaults.set(favoritesListSize, forKey: "history.favoritesListSize")
    }
}

class ControlsPreferences: PersistentPreferencesProtocol {
    
    var allowVolumeControl: Bool
    var allowSeeking: Bool
    var allowTrackChange: Bool
    
    var allowPlaylistNavigation: Bool
    var allowPlaylistTabToggle: Bool
    
    var volumeControlSensitivity: ScrollSensitivity
    var seekSensitivity: ScrollSensitivity
    
    internal required init(_ defaultsDictionary: [String: Any]) {
        
        let defaultsDictionary = Preferences.defaultsDict
        
        allowVolumeControl = defaultsDictionary["controls.allowVolumeControl"] as? Bool ?? PreferencesDefaults.Controls.allowVolumeControl
        
        allowSeeking = defaultsDictionary["controls.allowSeeking"] as? Bool ?? PreferencesDefaults.Controls.allowSeeking
        
        allowTrackChange = defaultsDictionary["controls.allowTrackChange"] as? Bool ?? PreferencesDefaults.Controls.allowTrackChange
        
        allowPlaylistNavigation = defaultsDictionary["controls.allowPlaylistNavigation"] as? Bool ?? PreferencesDefaults.Controls.allowPlaylistNavigation
        
        allowPlaylistTabToggle = defaultsDictionary["controls.allowPlaylistTabToggle"] as? Bool ?? PreferencesDefaults.Controls.allowPlaylistTabToggle
        
        if let volumeControlSensitivityStr = defaultsDictionary["controls.volumeControlSensitivity"] as? String {
            volumeControlSensitivity = ScrollSensitivity(rawValue: volumeControlSensitivityStr)!
        } else {
            volumeControlSensitivity = PreferencesDefaults.Controls.volumeControlSensitivity
        }
        
        if let seekSensitivityStr = defaultsDictionary["controls.seekSensitivity"] as? String {
            seekSensitivity = ScrollSensitivity(rawValue: seekSensitivityStr)!
        } else {
            seekSensitivity = PreferencesDefaults.Controls.seekSensitivity
        }
    }
    
    func persist(defaults: UserDefaults) {
        
        defaults.set(allowVolumeControl, forKey: "controls.allowVolumeControl")
        defaults.set(allowSeeking, forKey: "controls.allowSeeking")
        defaults.set(allowTrackChange, forKey: "controls.allowTrackChange")
        
        defaults.set(allowPlaylistNavigation, forKey: "controls.allowPlaylistNavigation")
        defaults.set(allowPlaylistTabToggle, forKey: "controls.allowPlaylistTabToggle")
        
        defaults.set(volumeControlSensitivity.rawValue, forKey: "controls.volumeControlSensitivity")
        defaults.set(seekSensitivity.rawValue, forKey: "controls.seekSensitivity")
    }
}

/*
    Container for default values for user preferences
 */
fileprivate struct PreferencesDefaults {
    
    struct Playback {
        
        static let seekLength: Int = 5
        static let autoplayOnStartup: Bool = false
        static let autoplayAfterAddingTracks: Bool = false
        static let autoplayAfterAddingOption: AutoplayAfterAddingOptions = .ifNotPlaying
    }
    
    struct Sound {
        
        static let volumeDelta: Float = 0.05
        
        static let volumeOnStartup: VolumeStartupOptions = .rememberFromLastAppLaunch
        static let startupVolumeValue: Float = 0.5
        
        static let panDelta: Float = 0.1
    }
    
    struct Playlist {
        
        static let playlistOnStartup: PlaylistStartupOptions = .rememberFromLastAppLaunch
    }
    
    struct View {
        
        static let viewOnStartup: ViewOnStartup = ViewOnStartup.defaultInstance
        static let windowLocationOnStartup: WindowLocationOnStartup = WindowLocationOnStartup.defaultInstance
        static let playlistLocationOnStartup: PlaylistLocationOnStartup = PlaylistLocationOnStartup.defaultInstance
    }
    
    struct History {
        
        static let recentlyAddedListSize: Int = 25
        static let recentlyPlayedListSize: Int = 25
        static let favoritesListSize: Int = 25
    }
    
    struct Controls {
        
        static let allowVolumeControl: Bool = true
        static let allowSeeking: Bool = true
        static let allowTrackChange: Bool = true
        
        static let allowPlaylistNavigation: Bool = true
        static let allowPlaylistTabToggle: Bool = true
        
        static let volumeControlSensitivity: ScrollSensitivity = .medium
        static let seekSensitivity: ScrollSensitivity = .medium
    }
}
