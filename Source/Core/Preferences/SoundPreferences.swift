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
    
    lazy var volumeDelta: UserPreference<Float> = .init(defaultsKey: "\(Self.keyPrefix).volumeDelta",
                                                                    defaultValue: Defaults.volumeDelta)
    
    private let scrollSensitiveVolumeDeltas: [GesturesControlsPreferences.ScrollSensitivity: Float] = [.low: 0.025, .medium: 0.05, .high: 0.1]
    
    var volumeDelta_continuous: Float {
        scrollSensitiveVolumeDeltas[controlsPreferences.volumeControlSensitivity.value]!
    }
    
    lazy var panDelta: UserPreference<Float> = .init(defaultsKey: "\(Self.keyPrefix).panDelta",
                                                                    defaultValue: Defaults.panDelta)
    
    lazy var eqDelta: UserPreference<Float> = .init(defaultsKey: "\(Self.keyPrefix).eqDelta",
                                                                    defaultValue: Defaults.eqDelta)
    
    lazy var pitchDelta: UserPreference<Int> = .init(defaultsKey: "\(Self.keyPrefix).pitchDelta",
                                                                    defaultValue: Defaults.pitchDelta)
    
    lazy var rateDelta: UserPreference<Float> = .init(defaultsKey: "\(Self.keyPrefix).rateDelta",
                                                                    defaultValue: Defaults.rateDelta)
    
    lazy var rememberEffectsSettingsForAllTracks: UserPreference<Bool> = .init(defaultsKey: "\(Self.keyPrefix).rememberEffectsSettingsForAllTracks",
                                                                    defaultValue: Defaults.rememberEffectsSettingsForAllTracks)
    
    private var controlsPreferences: GesturesControlsPreferences!

    init(controlsPreferences: GesturesControlsPreferences, legacyPreferences: LegacySoundPreferences? = nil) {
        
        self.controlsPreferences = controlsPreferences
        
        guard let legacyPreferences = legacyPreferences else {return}
        
        if let rateDelta = legacyPreferences.timeDelta {
            self.rateDelta.value = rateDelta
        }
        
        if let rememberEffectsSettingsOption = legacyPreferences.rememberEffectsSettingsOption {
            self.rememberEffectsSettingsForAllTracks.value = rememberEffectsSettingsOption == .allTracks
        }
        
        legacyPreferences.deleteAll()
    }
}
