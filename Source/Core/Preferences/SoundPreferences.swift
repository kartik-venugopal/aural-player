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
    
    private static let namespace: String = "sound"
    
    @UserPreference(key: "\(namespace).delta.volume", defaultValue: Defaults.volumeDelta)
    var volumeDelta: Float
    
    private let scrollSensitiveVolumeDeltas: [GesturesControlsPreferences.ScrollSensitivity: Float] = [
        .low: 2.5,
        .medium: 5,
        .high: 10
    ]
    
    var volumeDelta_continuous: Float {
        scrollSensitiveVolumeDeltas[controlsPreferences.volumeControlSensitivity]!
    }
    
    @UserPreference(key: "\(namespace).delta.pan", defaultValue: Defaults.panDelta)
    var panDelta: Float
    
    @UserPreference(key: "\(namespace).delta.eq", defaultValue: Defaults.eqDelta)
    var eqDelta: Float
    
    @UserPreference(key: "\(namespace).delta.pitchShift", defaultValue: Defaults.pitchShiftDelta)
    var pitchShiftDelta: Int
    
    @UserPreference(key: "\(namespace).delta.timeStretch", defaultValue: Defaults.timeStretchDelta)
    var timeStretchDelta: Float
    
    @UserPreference(key: "\(namespace).rememberEffectsSettingsForAllTracks", defaultValue: Defaults.rememberEffectsSettingsForAllTracks)
    var rememberEffectsSettingsForAllTracks: Bool
    
    private let controlsPreferences: GesturesControlsPreferences

    init(controlsPreferences: GesturesControlsPreferences, legacyPreferences: LegacySoundPreferences? = nil) {
        
        self.controlsPreferences = controlsPreferences
        
        guard let legacyPreferences = legacyPreferences else {return}
        
        if let rateDelta = legacyPreferences.timeDelta {
            self.timeStretchDelta = rateDelta
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
        
        static let volumeDelta: Float = 5
        static let panDelta: Float = 10
        
        static let eqDelta: Float = 1
        static let pitchShiftDelta: Int = 100
        static let timeStretchDelta: Float = 0.05
        
        static let rememberEffectsSettingsForAllTracks: Bool = false
    }
}
