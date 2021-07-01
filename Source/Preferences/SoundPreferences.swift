//
//  SoundPreferences.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class SoundPreferences: PersistentPreferencesProtocol {
    
    var outputDeviceOnStartup: OutputDeviceOnStartup
    
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
    
    var rememberEffectsSettingsOption: RememberSettingsForTrackOptions
    
    private var controlsPreferences: GesturesControlsPreferences!
    
    private static let keyPrefix: String = "sound"
    
    private static let key_outputDeviceOnStartupOption: String = "\(keyPrefix).outputDeviceOnStartup.option"
    private static let key_outputDeviceOnStartupPreferredDeviceName: String = "\(keyPrefix).outputDeviceOnStartup.preferredDeviceName"
    private static let key_outputDeviceOnStartupPreferredDeviceUID: String = "\(keyPrefix).outputDeviceOnStartup.preferredDeviceUID"
    
    private static let key_volumeDelta: String = "\(keyPrefix).volumeDelta"
    
    private static let key_volumeOnStartupOption: String = "\(keyPrefix).volumeOnStartup.option"
    private static let key_startupVolumeValue: String = "\(keyPrefix).volumeOnStartup.value"
    
    private static let key_panDelta: String = "\(keyPrefix).panDelta"
    
    private static let key_eqDelta: String = "\(keyPrefix).eqDelta"
    private static let key_pitchDelta: String = "\(keyPrefix).pitchDelta"
    private static let key_timeDelta: String = "\(keyPrefix).timeDelta"
    
    private static let key_effectsSettingsOnStartupOption: String = "\(keyPrefix).effectsSettingsOnStartup.option"
    private static let key_masterPresetOnStartup_name: String = "\(keyPrefix).effectsSettingsOnStartup.masterPreset"
    
    private static let key_rememberEffectsSettingsOption: String = "\(keyPrefix).rememberEffectsSettings.option"
    
    convenience init(_ defaults: [String: Any], _ controlsPreferences: GesturesControlsPreferences) {
        
        self.init(defaults)
        self.controlsPreferences = controlsPreferences
    }
    
    private typealias Defaults = PreferencesDefaults.Sound
    
    internal required init(_ dict: [String: Any]) {
        
        outputDeviceOnStartup = Defaults.outputDeviceOnStartup
        
        if let outputDeviceOnStartupOption = dict.enumValue(forKey: Self.key_outputDeviceOnStartupOption, ofType: OutputDeviceStartupOptions.self) {
            outputDeviceOnStartup.option = outputDeviceOnStartupOption
        }
        
        if let deviceName = dict.nonEmptyStringValue(forKey: Self.key_outputDeviceOnStartupPreferredDeviceName) {
            outputDeviceOnStartup.preferredDeviceName = deviceName
        }
        
        if let deviceUID = dict.nonEmptyStringValue(forKey: Self.key_outputDeviceOnStartupPreferredDeviceUID) {
            outputDeviceOnStartup.preferredDeviceUID = deviceUID
        }
        
        volumeDelta = dict.floatValue(forKey: Self.key_volumeDelta) ?? Defaults.volumeDelta
        
        volumeOnStartupOption = dict.enumValue(forKey: Self.key_volumeOnStartupOption, ofType: VolumeStartupOptions.self) ?? Defaults.volumeOnStartupOption
        
        startupVolumeValue = dict.floatValue(forKey: Self.key_volumeOnStartupOption) ?? Defaults.startupVolumeValue
        
        panDelta = dict.floatValue(forKey: Self.key_panDelta) ?? Defaults.panDelta
        
        eqDelta = dict.floatValue(forKey: Self.key_eqDelta) ?? Defaults.eqDelta
        pitchDelta = dict.intValue(forKey: Self.key_pitchDelta) ?? Defaults.pitchDelta
        timeDelta = dict.floatValue(forKey: Self.key_timeDelta) ?? Defaults.timeDelta
        
        effectsSettingsOnStartupOption = dict.enumValue(forKey: Self.key_effectsSettingsOnStartupOption, ofType: EffectsSettingsStartupOptions.self) ?? Defaults.effectsSettingsOnStartupOption
        
        masterPresetOnStartup_name = dict[Self.key_masterPresetOnStartup_name, String.self] ?? Defaults.masterPresetOnStartup_name
        
        rememberEffectsSettingsOption = dict.enumValue(forKey: Self.key_rememberEffectsSettingsOption, ofType: RememberSettingsForTrackOptions.self) ?? Defaults.rememberEffectsSettingsOption
        
        // Revert to default if data is corrupt (missing master preset)
        if effectsSettingsOnStartupOption == .applyMasterPreset && masterPresetOnStartup_name == nil {
            effectsSettingsOnStartupOption = .rememberFromLastAppLaunch
        }
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults[Self.key_outputDeviceOnStartupOption] = outputDeviceOnStartup.option.rawValue 
        defaults[Self.key_outputDeviceOnStartupPreferredDeviceName] = outputDeviceOnStartup.preferredDeviceName 
        defaults[Self.key_outputDeviceOnStartupPreferredDeviceUID] = outputDeviceOnStartup.preferredDeviceUID 
        
        defaults[Self.key_volumeDelta] = volumeDelta 
        
        defaults[Self.key_volumeOnStartupOption] = volumeOnStartupOption.rawValue 
        defaults[Self.key_startupVolumeValue] = startupVolumeValue 
        
        defaults[Self.key_panDelta] = panDelta 
        
        defaults[Self.key_eqDelta] = eqDelta 
        defaults[Self.key_pitchDelta] = pitchDelta 
        defaults[Self.key_timeDelta] = timeDelta 
        
        defaults[Self.key_effectsSettingsOnStartupOption] = effectsSettingsOnStartupOption.rawValue 
        defaults[Self.key_masterPresetOnStartup_name] = masterPresetOnStartup_name 
        
        defaults[Self.key_rememberEffectsSettingsOption] = rememberEffectsSettingsOption.rawValue 
    }
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

enum OutputDeviceStartupOptions: String {
    
    case rememberFromLastAppLaunch
    case system
    case specific
}

// All options for the volume at startup
enum VolumeStartupOptions: String {
    
    case rememberFromLastAppLaunch
    case specific
}

enum EffectsSettingsStartupOptions: String {
    
    case rememberFromLastAppLaunch
    case applyMasterPreset
}
