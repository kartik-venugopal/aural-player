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
    
    // General preferences
    
    var primarySeekLengthOption: SeekLengthOptions
    var primarySeekLengthConstant: Int
    var primarySeekLengthPercentage: Int
    
    var secondarySeekLengthOption: SeekLengthOptions
    var secondarySeekLengthConstant: Int
    var secondarySeekLengthPercentage: Int
    
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
    var rememberLastPositionOption: RememberSettingsForTrackOptions
    
    var gapBetweenTracks: Bool
    var gapBetweenTracksDuration: Int
    
    // Transcoding preferences
    
    var transcodingPreferences: TranscodingPreferences
    
    fileprivate convenience init(_ defaultsDictionary: [String: Any], _ controlsPreferences: ControlsPreferences) {
        self.init(defaultsDictionary)
        self.controlsPreferences = controlsPreferences
    }
    
    internal required init(_ defaultsDictionary: [String: Any]) {
        
        if let primarySeekLengthOptionStr = defaultsDictionary["playback.seekLength.primary.option"] as? String {
            primarySeekLengthOption = SeekLengthOptions(rawValue: primarySeekLengthOptionStr) ?? PreferencesDefaults.Playback.primarySeekLengthOption
        } else {
            primarySeekLengthOption = PreferencesDefaults.Playback.primarySeekLengthOption
        }
        
        primarySeekLengthConstant = defaultsDictionary["playback.seekLength.primary.constant"] as? Int ?? PreferencesDefaults.Playback.primarySeekLengthConstant
        primarySeekLengthPercentage = defaultsDictionary["playback.seekLength.primary.percentage"] as? Int ?? PreferencesDefaults.Playback.primarySeekLengthPercentage
        
        if let secondarySeekLengthOptionStr = defaultsDictionary["playback.seekLength.secondary.option"] as? String {
            secondarySeekLengthOption = SeekLengthOptions(rawValue: secondarySeekLengthOptionStr) ?? PreferencesDefaults.Playback.secondarySeekLengthOption
        } else {
            secondarySeekLengthOption = PreferencesDefaults.Playback.secondarySeekLengthOption
        }
        
        secondarySeekLengthConstant = defaultsDictionary["playback.seekLength.secondary.constant"] as? Int ?? PreferencesDefaults.Playback.secondarySeekLengthConstant
        secondarySeekLengthPercentage = defaultsDictionary["playback.seekLength.secondary.percentage"] as? Int ?? PreferencesDefaults.Playback.secondarySeekLengthPercentage
        
        autoplayOnStartup = defaultsDictionary["playback.autoplayOnStartup"] as? Bool ?? PreferencesDefaults.Playback.autoplayOnStartup
        
        autoplayAfterAddingTracks = defaultsDictionary["playback.autoplayAfterAddingTracks"] as? Bool ?? PreferencesDefaults.Playback.autoplayAfterAddingTracks
        
        if let autoplayAfterAddingOptionStr = defaultsDictionary["playback.autoplayAfterAddingTracks.option"] as? String {
            autoplayAfterAddingOption = AutoplayAfterAddingOptions(rawValue: autoplayAfterAddingOptionStr) ?? PreferencesDefaults.Playback.autoplayAfterAddingOption
        } else {
            autoplayAfterAddingOption = PreferencesDefaults.Playback.autoplayAfterAddingOption
        }
        
        showNewTrackInPlaylist = defaultsDictionary["playback.showNewTrackInPlaylist"] as? Bool ?? PreferencesDefaults.Playback.showNewTrackInPlaylist
        
        rememberLastPosition = defaultsDictionary["playback.rememberLastPosition"] as? Bool ?? PreferencesDefaults.Playback.rememberLastPosition
        
        if let optionStr = defaultsDictionary["playback.rememberLastPosition.option"] as? String {
            rememberLastPositionOption = RememberSettingsForTrackOptions(rawValue: optionStr) ?? PreferencesDefaults.Playback.rememberLastPositionOption
        } else {
            rememberLastPositionOption = PreferencesDefaults.Playback.rememberLastPositionOption
        }
        
        gapBetweenTracks = defaultsDictionary["playback.gapBetweenTracks"] as? Bool ?? PreferencesDefaults.Playback.gapBetweenTracks
        gapBetweenTracksDuration = defaultsDictionary["playback.gapBetweenTracks.duration"] as? Int ?? PreferencesDefaults.Playback.gapBetweenTracksDuration
        
        transcodingPreferences = TranscodingPreferences(defaultsDictionary)
    }
    
    func persist(defaults: UserDefaults) {
        
        defaults.set(primarySeekLengthOption.rawValue, forKey: "playback.seekLength.primary.option")
        defaults.set(primarySeekLengthConstant, forKey: "playback.seekLength.primary.constant")
        defaults.set(primarySeekLengthPercentage, forKey: "playback.seekLength.primary.percentage")
        
        defaults.set(secondarySeekLengthOption.rawValue, forKey: "playback.seekLength.secondary.option")
        defaults.set(secondarySeekLengthConstant, forKey: "playback.seekLength.secondary.constant")
        defaults.set(secondarySeekLengthPercentage, forKey: "playback.seekLength.secondary.percentage")
        
        defaults.set(autoplayOnStartup, forKey: "playback.autoplayOnStartup")
        defaults.set(autoplayAfterAddingTracks, forKey: "playback.autoplayAfterAddingTracks")
        defaults.set(autoplayAfterAddingOption.rawValue, forKey: "playback.autoplayAfterAddingTracks.option")
        
        defaults.set(showNewTrackInPlaylist, forKey: "playback.showNewTrackInPlaylist")
        
        defaults.set(rememberLastPosition, forKey: "playback.rememberLastPosition")
        defaults.set(rememberLastPositionOption.rawValue, forKey: "playback.rememberLastPosition.option")
        
        defaults.set(gapBetweenTracks, forKey: "playback.gapBetweenTracks")
        defaults.set(gapBetweenTracksDuration, forKey: "playback.gapBetweenTracks.duration")
        
        transcodingPreferences.persist(defaults: defaults)
    }
}

class TranscodingPreferences {
    
    var persistenceOption: TranscoderPersistenceOptions
    var limitDiskSpaceUsage: Bool
    var maxDiskSpaceUsage: Int // in MB
    
    var eagerTranscodingEnabled: Bool
    var eagerTranscodingOption: EagerTranscodingOptions
    var maxBackgroundTasks: Int
    
    internal required init(_ defaultsDictionary: [String: Any]) {
        
        if let transcoderPersistenceOptionStr = defaultsDictionary["playback.transcoding.persistence.option"] as? String {
            persistenceOption = TranscoderPersistenceOptions(rawValue: transcoderPersistenceOptionStr) ?? PreferencesDefaults.Playback.Transcoding.persistenceOption
        } else {
            persistenceOption = PreferencesDefaults.Playback.Transcoding.persistenceOption
        }
        
        limitDiskSpaceUsage = PreferencesDefaults.Playback.Transcoding.limitDiskSpaceUsage
        maxDiskSpaceUsage = PreferencesDefaults.Playback.Transcoding.maxDiskSpaceUsage
        
        //        limitDiskSpaceUsage = defaultsDictionary["playback.transcoding.persistence.limitDiskSpaceUsage"] as? Bool ?? PreferencesDefaults.Playback.Transcoding.limitDiskSpaceUsage
        //        maxDiskSpaceUsage = defaultsDictionary["playback.transcoding.persistence.maxDiskSpaceUsage"] as? Int ?? PreferencesDefaults.Playback.Transcoding.maxDiskSpaceUsage
        
        eagerTranscodingEnabled = PreferencesDefaults.Playback.Transcoding.eagerTranscodingEnabled
        
        //        if let eagerTranscodingOptionStr = defaultsDictionary["playback.transcoding.eagerTranscoding.option"] as? String {
        //            eagerTranscodingOption = EagerTranscodingOptions(rawValue: eagerTranscodingOptionStr) ?? PreferencesDefaults.Playback.Transcoding.eagerTranscodingOption
        //        } else {
        //            eagerTranscodingOption = PreferencesDefaults.Playback.Transcoding.eagerTranscodingOption
        //        }
        
        eagerTranscodingOption = PreferencesDefaults.Playback.Transcoding.eagerTranscodingOption
        
        //        maxBackgroundTasks = defaultsDictionary["playback.transcoding.maxBackgroundTasks"] as? Int ?? PreferencesDefaults.Playback.Transcoding.maxBackgroundTasks
        maxBackgroundTasks = PreferencesDefaults.Playback.Transcoding.maxBackgroundTasks
    }
    
    func persist(defaults: UserDefaults) {
        
        defaults.set(persistenceOption.rawValue, forKey: "playback.transcoding.persistence.option")
        //        defaults.set(limitDiskSpaceUsage, forKey: "playback.transcoding.persistence.limitDiskSpaceUsage")
        //        defaults.set(maxDiskSpaceUsage, forKey: "playback.transcoding.persistence.maxDiskSpaceUsage")
        //
        //        defaults.set(eagerTranscodingEnabled, forKey: "playback.transcoding.eagerTranscoding.enabled")
        //        defaults.set(eagerTranscodingOption.rawValue, forKey: "playback.transcoding.eagerTranscoding.option")
        //
        //        defaults.set(maxBackgroundTasks, forKey: "playback.transcoding.maxBackgroundTasks")
    }
}

class SoundPreferences: PersistentPreferencesProtocol {
    
    var volumeDelta: Float
    
    private let scrollSensitiveVolumeDeltas: [ScrollSensitivity: Float] = [.low: 0.025, .medium: 0.05, .high: 0.1]
    var volumeDelta_continuous: Float {
        return scrollSensitiveVolumeDeltas[controlsPreferences.volumeControlSensitivity]!
    }
    
    var volumeOnStartupOption: VolumeStartupOptions
    var startupVolumeValue: Float
    
    var panDelta: Float
    
    var eqDelta: Float
    var pitchDelta: Int
    var timeDelta: Float
    
    var effectsSettingsOnStartupOption: EffectsSettingsStartupOptions
    var masterPresetOnStartup_name: String?
    
    var rememberEffectsSettings: Bool
    var rememberEffectsSettingsOption: RememberSettingsForTrackOptions
    
    private var controlsPreferences: ControlsPreferences!
    
    fileprivate convenience init(_ defaultsDictionary: [String: Any], _ controlsPreferences: ControlsPreferences) {
        self.init(defaultsDictionary)
        self.controlsPreferences = controlsPreferences
    }
    
    internal required init(_ defaultsDictionary: [String: Any]) {
        
        let defaultsDictionary = Preferences.defaultsDict
        
        volumeDelta = defaultsDictionary["sound.volumeDelta"] as? Float ?? PreferencesDefaults.Sound.volumeDelta
        
        if let volumeOnStartupOptionStr = defaultsDictionary["sound.volumeOnStartup.option"] as? String {
            volumeOnStartupOption = VolumeStartupOptions(rawValue: volumeOnStartupOptionStr) ?? PreferencesDefaults.Sound.volumeOnStartupOption
        } else {
            volumeOnStartupOption = PreferencesDefaults.Sound.volumeOnStartupOption
        }
        
        startupVolumeValue = defaultsDictionary["sound.volumeOnStartup.value"] as? Float ?? PreferencesDefaults.Sound.startupVolumeValue
        
        panDelta = defaultsDictionary["sound.panDelta"] as? Float ?? PreferencesDefaults.Sound.panDelta
        
        eqDelta = defaultsDictionary["sound.eqDelta"] as? Float ?? PreferencesDefaults.Sound.eqDelta
        pitchDelta = defaultsDictionary["sound.pitchDelta"] as? Int ?? PreferencesDefaults.Sound.pitchDelta
        timeDelta = defaultsDictionary["sound.timeDelta"] as? Float ?? PreferencesDefaults.Sound.timeDelta
        
        if let effectsSettingsOnStartupOptionStr = defaultsDictionary["sound.effectsSettingsOnStartup.option"] as? String {
            effectsSettingsOnStartupOption = EffectsSettingsStartupOptions(rawValue: effectsSettingsOnStartupOptionStr) ?? PreferencesDefaults.Sound.effectsSettingsOnStartupOption
        } else {
            effectsSettingsOnStartupOption = PreferencesDefaults.Sound.effectsSettingsOnStartupOption
        }
        
        masterPresetOnStartup_name = defaultsDictionary["sound.effectsSettingsOnStartup.masterPreset"] as? String ?? PreferencesDefaults.Sound.masterPresetOnStartup_name
        
        rememberEffectsSettings = defaultsDictionary["sound.rememberEffectsSettings"] as? Bool ?? PreferencesDefaults.Sound.rememberEffectsSettings
        
        if let optionStr = defaultsDictionary["sound.rememberEffectsSettings.option"] as? String {
            rememberEffectsSettingsOption = RememberSettingsForTrackOptions(rawValue: optionStr) ?? PreferencesDefaults.Sound.rememberEffectsSettingsOption
        } else {
            rememberEffectsSettingsOption = PreferencesDefaults.Sound.rememberEffectsSettingsOption
        }
        
        // Revert to default if data is corrupt (missing master preset)
        if effectsSettingsOnStartupOption == .applyMasterPreset && masterPresetOnStartup_name == nil {
            effectsSettingsOnStartupOption = .rememberFromLastAppLaunch
        }
    }
    
    func persist(defaults: UserDefaults) {
        
        defaults.set(volumeDelta, forKey: "sound.volumeDelta")
        
        defaults.set(volumeOnStartupOption.rawValue, forKey: "sound.volumeOnStartup.option")
        defaults.set(startupVolumeValue, forKey: "sound.volumeOnStartup.value")
        
        defaults.set(panDelta, forKey: "sound.panDelta")
        
        defaults.set(eqDelta, forKey: "sound.eqDelta")
        defaults.set(pitchDelta, forKey: "sound.pitchDelta")
        defaults.set(timeDelta, forKey: "sound.timeDelta")
        
        defaults.set(effectsSettingsOnStartupOption.rawValue, forKey: "sound.effectsSettingsOnStartup.option")
        defaults.set(masterPresetOnStartup_name, forKey: "sound.effectsSettingsOnStartup.masterPreset")
        
        defaults.set(rememberEffectsSettings, forKey: "sound.rememberEffectsSettings")
        defaults.set(rememberEffectsSettingsOption.rawValue, forKey: "sound.rememberEffectsSettings.option")
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
        
        if let tracksFolderStr = defaultsDictionary["playlist.playlistOnStartup.tracksFolder"] as? String {
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
        defaults.set(tracksFolder?.path, forKey: "playlist.playlistOnStartup.tracksFolder")
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
    
    var respondToMediaKeys: Bool
    var skipKeyBehavior: SkipKeyBehavior
    var repeatSpeed: SkipKeyRepeatSpeed
    
    var allowVolumeControl: Bool
    var allowSeeking: Bool
    var allowTrackChange: Bool
    
    var allowPlaylistNavigation: Bool
    var allowPlaylistTabToggle: Bool
    
    var volumeControlSensitivity: ScrollSensitivity
    var seekSensitivity: ScrollSensitivity
    
    internal required init(_ defaultsDictionary: [String: Any]) {
        
        let defaultsDictionary = Preferences.defaultsDict
        
        // Media keys
        
        respondToMediaKeys = defaultsDictionary["controls.respondToMediaKeys"] as? Bool ?? PreferencesDefaults.Controls.respondToMediaKeys
        
        if let skipKeyBehaviorStr = defaultsDictionary["controls.skipKeyBehavior"] as? String {
            skipKeyBehavior = SkipKeyBehavior(rawValue: skipKeyBehaviorStr) ?? PreferencesDefaults.Controls.skipKeyBehavior
        } else {
            skipKeyBehavior = PreferencesDefaults.Controls.skipKeyBehavior
        }
        
        if let repeatSpeedStr = defaultsDictionary["controls.repeatSpeed"] as? String {
            repeatSpeed = SkipKeyRepeatSpeed(rawValue: repeatSpeedStr) ?? PreferencesDefaults.Controls.repeatSpeed
        } else {
            repeatSpeed = PreferencesDefaults.Controls.repeatSpeed
        }
        
        // Gestures
        
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
        
        defaults.set(respondToMediaKeys, forKey: "controls.respondToMediaKeys")
        defaults.set(skipKeyBehavior.rawValue, forKey: "controls.skipKeyBehavior")
        defaults.set(repeatSpeed.rawValue, forKey: "controls.repeatSpeed")
        
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
        
        static let primarySeekLengthOption: SeekLengthOptions = .constant
        static let primarySeekLengthConstant: Int = 5
        static let primarySeekLengthPercentage: Int = 2
        
        static let secondarySeekLengthOption: SeekLengthOptions = .constant
        static let secondarySeekLengthConstant: Int = 30
        static let secondarySeekLengthPercentage: Int = 10
        
        static let autoplayOnStartup: Bool = false
        static let autoplayAfterAddingTracks: Bool = false
        
        static let autoplayAfterAddingOption: AutoplayAfterAddingOptions = .ifNotPlaying
        static let showNewTrackInPlaylist: Bool = true
        
        static let rememberLastPosition: Bool = false
        static let rememberLastPositionOption: RememberSettingsForTrackOptions = .individualTracks
        
        static let gapBetweenTracks: Bool = false
        static let gapBetweenTracksDuration: Int = 5
        
        struct Transcoding {
            
            static let persistenceOption: TranscoderPersistenceOptions = .save
            static let limitDiskSpaceUsage: Bool = false
            static let maxDiskSpaceUsage: Int = 10000000
            
            //            static let limitDiskSpaceUsage: Bool = true
            //            static let maxDiskSpaceUsage: Int = 1000
            
            static let eagerTranscodingEnabled: Bool = false
            static let eagerTranscodingOption: EagerTranscodingOptions = .predictive
            
            //            static let eagerTranscodingEnabled: Bool = true
            //            static let eagerTranscodingOption: EagerTranscodingOptions = .allFiles
            
            static let maxBackgroundTasks: Int = 2
            
            //            static let maxBackgroundTasks: Int = {
            //
            //                let processorCount = ProcessInfo.processInfo.activeProcessorCount
            //                return processorCount > 2 ? (processorCount / 2) - 1 : 1
            //            }()
        }
    }
    
    struct Sound {
        
        static let volumeDelta: Float = 0.05
        
        static let volumeOnStartupOption: VolumeStartupOptions = .rememberFromLastAppLaunch
        static let startupVolumeValue: Float = 0.5
        
        static let panDelta: Float = 0.1
        
        static let eqDelta: Float = 1
        static let pitchDelta: Int = 100
        static let timeDelta: Float = 0.05
        
        static let effectsSettingsOnStartupOption: EffectsSettingsStartupOptions = .rememberFromLastAppLaunch
        static let masterPresetOnStartup_name: String? = nil
        
        static let rememberEffectsSettings: Bool = true
        static let rememberEffectsSettingsOption: RememberSettingsForTrackOptions = .individualTracks
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
        
        static let respondToMediaKeys: Bool = true
        static let skipKeyBehavior: SkipKeyBehavior = .hybrid
        static let repeatSpeed: SkipKeyRepeatSpeed = .medium
        
        static let allowVolumeControl: Bool = true
        static let allowSeeking: Bool = true
        static let allowTrackChange: Bool = true
        
        static let allowPlaylistNavigation: Bool = true
        static let allowPlaylistTabToggle: Bool = true
        
        static let volumeControlSensitivity: ScrollSensitivity = .medium
        static let seekSensitivity: ScrollSensitivity = .medium
    }
}

