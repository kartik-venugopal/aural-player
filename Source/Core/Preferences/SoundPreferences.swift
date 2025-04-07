//
//  SoundPreferences.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all user preferences pertaining to audio / sound.
///
class SoundPreferences {
    
    @UserPreference(key: "sound.volumeDelta", defaultValue: Defaults.volumeDelta)
    var volumeDelta: Float
    
    private let scrollSensitiveVolumeDeltas: [GesturesControlsPreferences.ScrollSensitivity: Float] = [
        .low: 0.025,
        .medium: 0.05,
        .high: 0.1
    ]
    
    var volumeDelta_continuous: Float {
        scrollSensitiveVolumeDeltas[controlsPreferences.volumeControlSensitivity]!
    }
    
    @UserPreference(key: "sound.panDelta", defaultValue: Defaults.panDelta)
    var panDelta: Float
    
    @UserPreference(key: "sound.eqDelta", defaultValue: Defaults.eqDelta)
    var eqDelta: Float
    
    @UserPreference(key: "sound.pitchDelta", defaultValue: Defaults.pitchDelta)
    var pitchDelta: Int
    
    @UserPreference(key: "sound.rateDelta", defaultValue: Defaults.rateDelta)
    var rateDelta: Float
    
    @UserPreference(key: "sound.rememberEffectsSettingsForAllTracks", defaultValue: Defaults.rememberEffectsSettingsForAllTracks)
    var rememberEffectsSettingsForAllTracks: Bool
    
    private let controlsPreferences: GesturesControlsPreferences

    init(controlsPreferences: GesturesControlsPreferences, legacyPreferences: LegacySoundPreferences? = nil) {
        
        self.controlsPreferences = controlsPreferences
        
        guard let legacyPreferences = legacyPreferences else {return}
        
        if let rateDelta = legacyPreferences.timeDelta {
            self.rateDelta = rateDelta
        }
        
        if let rememberEffectsSettingsOption = legacyPreferences.rememberEffectsSettingsOption {
            self.rememberEffectsSettingsForAllTracks = rememberEffectsSettingsOption == .allTracks
        }
        
        legacyPreferences.deleteAll()
    }
    
    ///
    /// An enumeration of default values for audio / sound preferences.
    ///
    fileprivate struct Defaults {
        
        static let volumeDelta: Float = 0.05
        static let panDelta: Float = 0.1
        
        static let eqDelta: Float = 1
        static let pitchDelta: Int = 100
        static let rateDelta: Float = 0.05
        
        static let rememberEffectsSettingsForAllTracks: Bool = false
    }
}
