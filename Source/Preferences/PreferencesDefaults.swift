import Cocoa

/*
 Container for default values for user preferences
 */
struct PreferencesDefaults {
    
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
        
        static let rememberLastPosition: Bool = false
        static let rememberLastPositionOption: RememberSettingsForTrackOptions = .individualTracks
    }
    
    struct Sound {
        
        static let outputDeviceOnStartup: OutputDeviceOnStartup = OutputDeviceOnStartup.defaultInstance
        
        static let volumeDelta: Float = 0.05
        
        static let volumeOnStartupOption: VolumeStartupOptions = .rememberFromLastAppLaunch
        static let startupVolumeValue: Float = 0.5
        
        static let panDelta: Float = 0.1
        
        static let eqDelta: Float = 1
        static let pitchDelta: Int = 100
        static let timeDelta: Float = 0.05
        
        static let effectsSettingsOnStartupOption: EffectsSettingsStartupOptions = .rememberFromLastAppLaunch
        static let masterPresetOnStartup_name: String? = nil
        
        static let rememberEffectsSettingsOption: RememberSettingsForTrackOptions = .individualTracks
    }
    
    struct Playlist {
        
        static let playlistOnStartup: PlaylistStartupOptions = .rememberFromLastAppLaunch
        static let playlistFile: URL? = nil
        static let tracksFolder: URL? = nil
        
        static let viewOnStartup: PlaylistViewOnStartup = PlaylistViewOnStartup.defaultInstance
        
        static let showNewTrackInPlaylist: Bool = true
        static let showChaptersList: Bool = true
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
    
    struct Metadata {
        
        struct MusicBrainz {
            
            static let enableCoverArtSearch: Bool = true
            static let enableOnDiskCoverArtCache: Bool = true
        }
    }
}
