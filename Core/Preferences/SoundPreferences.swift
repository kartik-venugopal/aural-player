//
//  SoundPreferences.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all user preferences pertaining to audio / sound.
///
class SoundPreferences {
    
    var outputDeviceOnStartup: OutputDeviceOnStartup = .defaultInstance
    
    var volumeDelta: Float = 0.05
    
    private let scrollSensitiveVolumeDeltas: [ScrollSensitivity: Float] = [.low: 0.025, .medium: 0.05, .high: 0.1]
    
    var volumeDelta_continuous: Float {
        scrollSensitiveVolumeDeltas[controlsPreferences.volumeControlSensitivity]!
    }
    
    var volumeOnStartupOption: VolumeStartupOptions = .rememberFromLastAppLaunch
    var startupVolumeValue: Float = 0.5
    
    var panDelta: Float = 0.1
    
    var eqDelta: Float = 1
    var pitchDelta: Int = 10
    var timeDelta: Float = 0.05
    
    var effectsSettingsOnStartupOption: EffectsSettingsStartupOptions = .applyMasterPreset
    var masterPresetOnStartup_name: String?
    
    var rememberEffectsSettingsOption: RememberSettingsForTrackOption = .allTracks
    
    private var controlsPreferences: GesturesControlsPreferences!
    
    private static let keyPrefix: String = "sound"
    
    static let key_outputDeviceOnStartup_option: String = "\(keyPrefix).outputDeviceOnStartup.option"
    static let key_outputDeviceOnStartup_preferredDeviceName: String = "\(keyPrefix).outputDeviceOnStartup.preferredDeviceName"
    static let key_outputDeviceOnStartup_preferredDeviceUID: String = "\(keyPrefix).outputDeviceOnStartup.preferredDeviceUID"
    
    static let key_volumeDelta: String = "\(keyPrefix).volumeDelta"
    
    static let key_volumeOnStartup_option: String = "\(keyPrefix).volumeOnStartup.option"
    static let key_volumeOnStartup_value: String = "\(keyPrefix).volumeOnStartup.value"
    
    static let key_panDelta: String = "\(keyPrefix).panDelta"
    
    static let key_eqDelta: String = "\(keyPrefix).eqDelta"
    static let key_pitchDelta: String = "\(keyPrefix).pitchDelta"
    static let key_timeDelta: String = "\(keyPrefix).timeDelta"
    
    static let key_effectsSettingsOnStartup_option: String = "\(keyPrefix).effectsSettingsOnStartup.option"
    static let key_effectsSettingsOnStartup_masterPreset: String = "\(keyPrefix).effectsSettingsOnStartup.masterPreset"
    
    static let key_rememberEffectsSettingsOption: String = "\(keyPrefix).rememberEffectsSettings.option"
    
    init(controlsPreferences: GesturesControlsPreferences) {
        self.controlsPreferences = controlsPreferences
    }
    
    private typealias Defaults = PreferencesDefaults.Sound
}

// Window layout on startup preference
class OutputDeviceOnStartup {
    
    var option: OutputDeviceStartupOptions = .system
    
    // This is used only if option == .specific
    var preferredDeviceName: String? = nil
    var preferredDeviceUID: String? = nil
    
    // NOTE: This is mutable. Potentially unsafe (convert variable into factory method ???)
    static let defaultInstance: OutputDeviceOnStartup = OutputDeviceOnStartup()
}

enum OutputDeviceStartupOptions: String, CaseIterable {
    
    case rememberFromLastAppLaunch
    case system
    case specific
}

// All options for the volume at startup
enum VolumeStartupOptions: String, CaseIterable {
    
    case rememberFromLastAppLaunch
    case specific
}

enum EffectsSettingsStartupOptions: String, CaseIterable {
    
    case rememberFromLastAppLaunch
    case applyMasterPreset
}
