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
        
        switch controlsPreferences.seekSensitivity {
            
        case .low:
            return 2.5
            
        case .medium:
            return 5
            
        case .high:
            return 10
        }
    }
    
    @UserPreference(key: "playback.rememberLastPositionForAllTracks", defaultValue: Defaults.rememberLastPositionForAllTracks)
    var rememberLastPositionForAllTracks: Bool
    
    let autoplay: AutoplayPlaybackPreferences
    private let controlsPreferences: GesturesControlsPreferences
    
    init(controlsPreferences: GesturesControlsPreferences, legacyPreferences: LegacyPlaybackPreferences? = nil) {

        self.autoplay = AutoplayPlaybackPreferences()
        self.controlsPreferences = controlsPreferences
        
        guard let legacyPreferences = legacyPreferences else {return}
        
        if let rememberLastPositionOption = legacyPreferences.rememberLastPositionOption {
            self.rememberLastPositionForAllTracks = rememberLastPositionOption == .allTracks
        }
        
        legacyPreferences.deleteAll()
    }

    public enum SeekLengthOption: String, CaseIterable {
        
        case constant
        case percentage
    }
    
    enum RememberSettingsForTrackOption: String, CaseIterable {
        
        case allTracks
        case individualTracks
    }
    
    ///
    /// An enumeration of default values for playback preferences.
    ///
    struct Defaults {
        
        static let primarySeekLengthOption: SeekLengthOption = .constant
        static let primarySeekLengthConstant: Int = 5
        static let primarySeekLengthPercentage: Int = 2
        
        static let secondarySeekLengthOption: SeekLengthOption = .constant
        static let secondarySeekLengthConstant: Int = 30
        static let secondarySeekLengthPercentage: Int = 10
        
        static let rememberLastPositionForAllTracks: Bool = false
    }
}
