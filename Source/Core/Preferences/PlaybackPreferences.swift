//
//  PlaybackPreferences.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// Encapsulates all user preferences pertaining to track playback.
///
class PlaybackPreferences {
    
    private static let keyPrefix: String = "playback"
    
    private typealias Defaults = PreferencesDefaults.Playback
    
    private let controlsPreferences: GesturesControlsPreferences
    
    init(controlsPreferences: GesturesControlsPreferences, legacyPreferences: LegacyPlaybackPreferences? = nil) {
        
        self.controlsPreferences = controlsPreferences
        
        guard let legacyPreferences = legacyPreferences else {return}
        
        if let rememberLastPositionOption = legacyPreferences.rememberLastPositionOption {
            self.rememberLastPositionForAllTracks = rememberLastPositionOption == .allTracks
        }
        
        legacyPreferences.deleteAll()
    }
    
    // General preferences
    @EnumUserPreference(key: "playback.seekLength.primary.option", defaultValue: Defaults.primarySeekLengthOption)
    var primarySeekLengthOption: SeekLengthOption
    
    @UserPreference(key: "playback.seekLength.primary.constant", defaultValue: Defaults.primarySeekLengthConstant)
    var primarySeekLengthConstant: Int
    
    @UserPreference(key: "playback.seekLength.primary.percentage", defaultValue: Defaults.primarySeekLengthPercentage)
    var primarySeekLengthPercentage: Int
    
    @EnumUserPreference(key: "playback.seekLength.secondary.option", defaultValue: Defaults.secondarySeekLengthOption)
    var secondarySeekLengthOption: SeekLengthOption
    
    @UserPreference(key: "playback.seekLength.secondary.constant", defaultValue: Defaults.secondarySeekLengthConstant)
    var secondarySeekLengthConstant: Int
    
    @UserPreference(key: "playback.seekLength.secondary.percentage", defaultValue: Defaults.secondarySeekLengthPercentage)
    var secondarySeekLengthPercentage: Int
    
    var seekLength_continuous: Double {
        
        switch controlsPreferences.seekSensitivity.value {
            
        case .low:
            return 2.5
            
        case .medium:
            return 5
            
        case .high:
            return 10
        }
    }
    
    @UserPreference(key: "playback.autoplay.onStartup", defaultValue: Defaults.autoplayOnStartup)
    var autoplayOnStartup: Bool
    
    @EnumUserPreference(key: "playback.autoplay.onStartup.option", defaultValue: Defaults.autoplayOnStartupOption)
    var autoplayOnStartupOption: AutoplayOnStartupOption
    
    @UserPreference(key: "playback.autoplay.afterAddingTracks", defaultValue: Defaults.autoplayAfterAddingTracks)
    var autoplayAfterAddingTracks: Bool
    
    @EnumUserPreference(key: "playback.autoplay.afterAddingTracks.option", defaultValue: Defaults.autoplayAfterAddingOption)
    var autoplayAfterAddingOption: AutoplayAfterAddingOption
    
    @UserPreference(key: "playback.autoplay.afterOpeningTracks", defaultValue: Defaults.autoplayAfterOpeningTracks)
    var autoplayAfterOpeningTracks: Bool
    
    @EnumUserPreference(key: "playback.autoplay.afterOpeningTracks.option", defaultValue: Defaults.autoplayAfterOpeningOption)
    var autoplayAfterOpeningOption: AutoplayAfterOpeningOption
    
    @UserPreference(key: "playback.rememberLastPositionForAllTracks", defaultValue: Defaults.rememberLastPositionForAllTracks)
    var rememberLastPositionForAllTracks: Bool

    public enum SeekLengthOption: String, CaseIterable {
        
        case constant
        case percentage
    }
    
    enum AutoplayOnStartupOption: String, CaseIterable {
        
        case firstTrack
        case resumeSequence
    }

    // Possible options for the "autoplay afer adding tracks" user preference
    enum AutoplayAfterAddingOption: String, CaseIterable {
        
        case ifNotPlaying
        case always
    }

    // Possible options for the "autoplay afer 'Open With'" user preference
    enum AutoplayAfterOpeningOption: String, CaseIterable {

        case ifNotPlaying
        case always
    }

    enum RememberSettingsForTrackOption: String, CaseIterable {
        
        case allTracks
        case individualTracks
    }
}
