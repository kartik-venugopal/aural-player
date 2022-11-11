//
//  PreferencesDefaults.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// An enumeration of default values for user preferences.
///
struct PreferencesDefaults {

    ///
    /// An enumeration of default values for playback preferences.
    ///
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
        
        static let rememberLastPositionOption: RememberSettingsForTrackOptions = .individualTracks
    }
    
    ///
    /// An enumeration of default values for audio / sound preferences.
    ///
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
    
    ///
    /// An enumeration of default values for playlist preferences.
    ///
    struct Playlist {
        
        static let playlistOnStartup: PlaylistStartupOptions = .rememberFromLastAppLaunch
        static let playlistFile: URL? = nil
        static let tracksFolder: URL? = nil
        
        static let viewOnStartup: PlaylistViewOnStartup = PlaylistViewOnStartup.defaultInstance
        
        static let showNewTrackInPlaylist: Bool = true
        static let showChaptersList: Bool = true
    }
    
    ///
    /// An enumeration of default values for UI / view preferences.
    ///
    struct View {
        
        static let appModeOnStartup: AppModeOnStartup = AppModeOnStartup.defaultInstance
        static let layoutOnStartup: LayoutOnStartup = LayoutOnStartup.defaultInstance
        static let snapToWindows: Bool = true
        static let snapToScreen: Bool = true
        static let windowGap: Float = 0
    }
    
    ///
    /// An enumeration of default values for history preferences.
    ///
    struct History {
        
        static let recentlyAddedListSize: Int = 25
        static let recentlyPlayedListSize: Int = 25
    }
    
    ///
    /// An enumeration of default values for usability / controls preferences.
    ///
    struct Controls {
        
        ///
        /// An enumeration of default values for media keys preferences.
        ///
        struct MediaKeys {
            
            static let enabled: Bool = true
            static let skipKeyBehavior: SkipKeyBehavior = .hybrid
            static let repeatSpeed: SkipKeyRepeatSpeed = .medium
        }
        
        ///
        /// An enumeration of default values for trackpad / mouse gestures preferences.
        ///
        struct Gestures {
            
            static let allowVolumeControl: Bool = true
            static let allowSeeking: Bool = true
            static let allowTrackChange: Bool = true
            
            static let allowPlaylistNavigation: Bool = true
            static let allowPlaylistTabToggle: Bool = true
            
            static let volumeControlSensitivity: ScrollSensitivity = .medium
            static let seekSensitivity: ScrollSensitivity = .medium
            
        }
        
        ///
        /// An enumeration of default values for **Remote Control** preferences.
        ///
        struct RemoteControl {
            
            static let enabled: Bool = true
            static let trackChangeOrSeekingOption: TrackChangeOrSeekingOptions = .trackChange
        }
    }
    
    ///
    /// An enumeration of default values for metadata retrieval preferences.
    ///
    struct Metadata {
    
        ///
        /// An enumeration of default values for **MusicBrainz** metadata retrieval preferences.
        ///
        struct MusicBrainz {
            
            static let httpTimeout: Int = 5
            static let enableCoverArtSearch: Bool = true
            static let enableOnDiskCoverArtCache: Bool = true
        }
    }
}
