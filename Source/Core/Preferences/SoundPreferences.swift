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
    
    private static let keyPrefix: String = "sound"
    private typealias Defaults = PreferencesDefaults.Sound
    
    @UserPreference(key: "sound.volumeDelta", defaultValue: Defaults.volumeDelta)
    var volumeDelta: Float
    
    private let scrollSensitiveVolumeDeltas: [GesturesControlsPreferences.ScrollSensitivity: Float] = [
        .low: 0.025,
        .medium: 0.05,
        .high: 0.1
    ]
    
    var volumeDelta_continuous: Float {
        scrollSensitiveVolumeDeltas[controlsPreferences.volumeControlSensitivity.value]!
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
    
    private var controlsPreferences: GesturesControlsPreferences!

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
}
