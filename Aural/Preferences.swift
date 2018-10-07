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
    
    var showNewTrackInPlaylist: Bool
    
    var rememberLastPosition: Bool
    
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
        
        showNewTrackInPlaylist = defaultsDictionary["playback.showNewTrackInPlaylist"] as? Bool ?? PreferencesDefaults.Playback.showNewTrackInPlaylist
        
        rememberLastPosition = defaultsDictionary["playback.rememberLastPosition"] as? Bool ?? PreferencesDefaults.Playback.rememberLastPosition
    }
    
    func persist(defaults: UserDefaults) {
        
        defaults.set(seekLength, forKey: "playback.seekLength")
        
        defaults.set(autoplayOnStartup, forKey: "playback.autoplayOnStartup")
        defaults.set(autoplayAfterAddingTracks, forKey: "playback.autoplayAfterAddingTracks")
        defaults.set(autoplayAfterAddingOption.rawValue, forKey: "playback.autoplayAfterAddingTracks.option")
        
        defaults.set(showNewTrackInPlaylist, forKey: "playback.showNewTrackInPlaylist")
        defaults.set(rememberLastPosition, forKey: "playback.rememberLastPosition")
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
    
    var rememberSettingsPerTrack: Bool
    var rememberSettingsPerTrackOption: RememberSettingsPerTrackOptions
    
    private var controlsPreferences: ControlsPreferences!
    
    fileprivate convenience init(_ defaultsDictionary: [String: Any], _ controlsPreferences: ControlsPreferences) {
        self.init(defaultsDictionary)
        self.controlsPreferences = controlsPreferences
    }
    
    internal required init(_ defaultsDictionary: [String: Any]) {
        
        let defaultsDictionary = Preferences.defaultsDict
        
        volumeDelta = defaultsDictionary["sound.volumeDelta"] as? Float ?? PreferencesDefaults.Sound.volumeDelta
        
        if let volumeOnStartupStr = defaultsDictionary["sound.volumeOnStartup"] as? String {
            volumeOnStartup = VolumeStartupOptions(rawValue: volumeOnStartupStr) ?? PreferencesDefaults.Sound.volumeOnStartup
        } else {
            volumeOnStartup = PreferencesDefaults.Sound.volumeOnStartup
        }
        
        startupVolumeValue = defaultsDictionary["sound.startupVolumeValue"] as? Float ?? PreferencesDefaults.Sound.startupVolumeValue
        
        panDelta = defaultsDictionary["sound.panDelta"] as? Float ?? PreferencesDefaults.Sound.panDelta
        
        rememberSettingsPerTrack = defaultsDictionary["sound.rememberSettingsPerTrack"] as? Bool ?? PreferencesDefaults.Sound.rememberSoundSettingsPerTrack
        
        if let optionStr = defaultsDictionary["sound.rememberSettingsPerTrack.option"] as? String {
            rememberSettingsPerTrackOption = RememberSettingsPerTrackOptions(rawValue: optionStr) ?? PreferencesDefaults.Sound.rememberSoundSettingsPerTrackOption
        } else {
            rememberSettingsPerTrackOption = PreferencesDefaults.Sound.rememberSoundSettingsPerTrackOption
        }
    }
    
    func persist(defaults: UserDefaults) {
        
        defaults.set(volumeDelta, forKey: "sound.volumeDelta")
        
        defaults.set(volumeOnStartup.rawValue, forKey: "sound.volumeOnStartup")
        defaults.set(startupVolumeValue, forKey: "sound.startupVolumeValue")
        
        defaults.set(panDelta, forKey: "sound.panDelta")
        
        defaults.set(rememberSettingsPerTrack, forKey: "sound.rememberSettingsPerTrack")
        defaults.set(rememberSettingsPerTrackOption.rawValue, forKey: "sound.rememberSettingsPerTrack.option")
    }
}

class PlaylistPreferences: PersistentPreferencesProtocol {
    
    var playlistOnStartup: PlaylistStartupOptions
    
    // This will be used only when playlistOnStartup == PlaylistStartupOptions.loadFile
    var playlistFile: URL?
    
    // This will be used only when playlistOnStartup == PlaylistStartupOptions.loadFolder
    var tracksFolder: URL?
    
    internal required init(_ defaultsDictionary: [String: Any]) {
        
        if let playlistOnStartupStr = defaultsDictionary["playlist.playlistOnStartup"] as? String {
            playlistOnStartup = PlaylistStartupOptions(rawValue: playlistOnStartupStr)!
        } else {
            playlistOnStartup = PreferencesDefaults.Playlist.playlistOnStartup
        }
        
        if let playlistFileStr = defaultsDictionary["playlist.playlistOnStartup.playlistFile"] as? String {
            playlistFile = URL(fileURLWithPath: playlistFileStr)
        } else {
            playlistFile = PreferencesDefaults.Playlist.playlistFile
        }
        
        // If .loadFile selected but no file available to load from, revert back to defaults
        if (playlistOnStartup == .loadFile && playlistFile == nil) {
            
            playlistOnStartup = PreferencesDefaults.Playlist.playlistOnStartup
            playlistFile = PreferencesDefaults.Playlist.playlistFile
        }
        
        if let tracksFolderStr = defaultsDictionary["playlist.playlistOnStartup.tracksFolderx"] as? String {
            tracksFolder = URL(fileURLWithPath: tracksFolderStr)
        } else {
            tracksFolder = PreferencesDefaults.Playlist.tracksFolder
        }
        
        // If .loadFolder selected but no folder available to load from, revert back to defaults
        if (playlistOnStartup == .loadFolder && tracksFolder == nil) {
            
            playlistOnStartup = PreferencesDefaults.Playlist.playlistOnStartup
            tracksFolder = PreferencesDefaults.Playlist.tracksFolder
        }
    }
    
    func persist(defaults: UserDefaults) {
        
        defaults.set(playlistOnStartup.rawValue, forKey: "playlist.playlistOnStartup")
        defaults.set(playlistFile?.path, forKey: "playlist.playlistOnStartup.playlistFile")
        defaults.set(tracksFolder?.path, forKey: "playlist.playlistOnStartup.tracksFolderx")
    }
}

class ViewPreferences: PersistentPreferencesProtocol {
 
    var layoutOnStartup: LayoutOnStartup
    var snapToWindows: Bool
    var snapToScreen: Bool
    
    // Only used when snapToWindows == true
    var windowGap: Float
    
    internal required init(_ defaultsDictionary: [String: Any]) {
        
        layoutOnStartup = PreferencesDefaults.View.layoutOnStartup
        snapToWindows = PreferencesDefaults.View.snapToWindows
        snapToScreen = PreferencesDefaults.View.snapToScreen
        windowGap = PreferencesDefaults.View.windowGap
        
        if let layoutOnStartupOptionStr = defaultsDictionary["view.layoutOnStartup.option"] as? String {
            layoutOnStartup.option = ViewStartupOptions(rawValue: layoutOnStartupOptionStr)!
        }
        
        if let layoutStr = defaultsDictionary["view.layoutOnStartup.layout"] as? String {
            layoutOnStartup.layoutName = layoutStr
        }
        
        if let snap2Windows = defaultsDictionary["view.snap.toWindows"] as? Bool {
            snapToWindows = snap2Windows
        }
        
        if let gap = defaultsDictionary["view.snap.toWindows.gap"] as? Float {
            windowGap = gap
        }
        
        if let snap2Screen = defaultsDictionary["view.snap.toScreen"] as? Bool {
            snapToScreen = snap2Screen
        }
    }
    
    func persist(defaults: UserDefaults) {
        
        defaults.set(layoutOnStartup.option.rawValue, forKey: "view.layoutOnStartup.option")
        defaults.set(layoutOnStartup.layoutName, forKey: "view.layoutOnStartup.layout")
        defaults.set(snapToWindows, forKey: "view.snap.toWindows")
        defaults.set(windowGap, forKey: "view.snap.toWindows.gap")
        defaults.set(snapToScreen, forKey: "view.snap.toScreen")
    }
}

class HistoryPreferences: PersistentPreferencesProtocol {
    
    var recentlyAddedListSize: Int
    var recentlyPlayedListSize: Int
    
    internal required init(_ defaultsDictionary: [String: Any]) {
        
        let defaultsDictionary = Preferences.defaultsDict
        
        recentlyAddedListSize = defaultsDictionary["history.recentlyAddedListSize"] as? Int ?? PreferencesDefaults.History.recentlyAddedListSize
        recentlyPlayedListSize = defaultsDictionary["history.recentlyPlayedListSize"] as? Int ?? PreferencesDefaults.History.recentlyPlayedListSize
    }
    
    func persist(defaults: UserDefaults) {
        
        defaults.set(recentlyAddedListSize, forKey: "history.recentlyAddedListSize")
        defaults.set(recentlyPlayedListSize, forKey: "history.recentlyPlayedListSize")
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
        static let showNewTrackInPlaylist: Bool = true
        static let rememberLastPosition: Bool = false
    }
    
    struct Sound {
        
        static let volumeDelta: Float = 0.05
        
        static let volumeOnStartup: VolumeStartupOptions = .rememberFromLastAppLaunch
        static let startupVolumeValue: Float = 0.5
        
        static let panDelta: Float = 0.1
        
        static let rememberSoundSettingsPerTrack: Bool = true
        static let rememberSoundSettingsPerTrackOption: RememberSettingsPerTrackOptions = .individualTracks
    }
    
    struct Playlist {
        
        static let playlistOnStartup: PlaylistStartupOptions = .rememberFromLastAppLaunch
        static let playlistFile: URL? = nil
        static let tracksFolder: URL? = nil
    }
    
    struct View {
        
        static let layoutOnStartup: LayoutOnStartup = LayoutOnStartup.defaultInstance
        static let snapToWindows: Bool = true
        static let snapToScreen: Bool = true
        static let windowGap: Float = 0
    }
    
    struct History {
        
        static let recentlyAddedListSize: Int = 25
        static let recentlyPlayedListSize: Int = 25
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
