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
    
    convenience init(_ defaults: [String: Any], _ controlsPreferences: GesturesControlsPreferences) {
        
        self.init(defaults)
        self.controlsPreferences = controlsPreferences
    }
    
    private typealias Defaults = PreferencesDefaults.Sound
    
    internal required init(_ dict: [String: Any]) {
        
        outputDeviceOnStartup = Defaults.outputDeviceOnStartup
        
        if let outputDeviceOnStartupOption = dict.enumValue(forKey: "sound.outputDeviceOnStartup.option", ofType: OutputDeviceStartupOptions.self) {
            outputDeviceOnStartup.option = outputDeviceOnStartupOption
        }
        
        if let deviceName = dict.nonEmptyStringValue(forKey: "sound.outputDeviceOnStartup.preferredDeviceName") {
            outputDeviceOnStartup.preferredDeviceName = deviceName
        }
        
        if let deviceUID = dict.nonEmptyStringValue(forKey: "sound.outputDeviceOnStartup.preferredDeviceUID") {
            outputDeviceOnStartup.preferredDeviceUID = deviceUID
        }
        
        volumeDelta = dict["sound.volumeDelta", Float.self] ?? Defaults.volumeDelta
        
        volumeOnStartupOption = dict.enumValue(forKey: "sound.volumeOnStartup.option", ofType: VolumeStartupOptions.self) ?? Defaults.volumeOnStartupOption
        
        startupVolumeValue = dict["sound.volumeOnStartup.value", Float.self] ?? Defaults.startupVolumeValue
        
        panDelta = dict["sound.panDelta", Float.self] ?? Defaults.panDelta
        
        eqDelta = dict["sound.eqDelta", Float.self] ?? Defaults.eqDelta
        pitchDelta = dict["sound.pitchDelta", Int.self] ?? Defaults.pitchDelta
        timeDelta = dict["sound.timeDelta", Float.self] ?? Defaults.timeDelta
        
        effectsSettingsOnStartupOption = dict.enumValue(forKey: "sound.effectsSettingsOnStartup.option", ofType: EffectsSettingsStartupOptions.self) ?? Defaults.effectsSettingsOnStartupOption
        
        masterPresetOnStartup_name = dict["sound.effectsSettingsOnStartup.masterPreset", String.self] ?? Defaults.masterPresetOnStartup_name
        
        rememberEffectsSettingsOption = dict.enumValue(forKey: "sound.rememberEffectsSettings.option", ofType: RememberSettingsForTrackOptions.self) ?? Defaults.rememberEffectsSettingsOption
        
        // Revert to default if data is corrupt (missing master preset)
        if effectsSettingsOnStartupOption == .applyMasterPreset && masterPresetOnStartup_name == nil {
            effectsSettingsOnStartupOption = .rememberFromLastAppLaunch
        }
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults.set(outputDeviceOnStartup.option.rawValue, forKey: "sound.outputDeviceOnStartup.option")
        defaults.set(outputDeviceOnStartup.preferredDeviceName, forKey: "sound.outputDeviceOnStartup.preferredDeviceName")
        defaults.set(outputDeviceOnStartup.preferredDeviceUID, forKey: "sound.outputDeviceOnStartup.preferredDeviceUID")
        
        defaults.set(volumeDelta, forKey: "sound.volumeDelta")
        
        defaults.set(volumeOnStartupOption.rawValue, forKey: "sound.volumeOnStartup.option")
        defaults.set(startupVolumeValue, forKey: "sound.volumeOnStartup.value")
        
        defaults.set(panDelta, forKey: "sound.panDelta")
        
        defaults.set(eqDelta, forKey: "sound.eqDelta")
        defaults.set(pitchDelta, forKey: "sound.pitchDelta")
        defaults.set(timeDelta, forKey: "sound.timeDelta")
        
        defaults.set(effectsSettingsOnStartupOption.rawValue, forKey: "sound.effectsSettingsOnStartup.option")
        defaults.set(masterPresetOnStartup_name, forKey: "sound.effectsSettingsOnStartup.masterPreset")
        
        defaults.set(rememberEffectsSettingsOption.rawValue, forKey: "sound.rememberEffectsSettings.option")
    }
}
