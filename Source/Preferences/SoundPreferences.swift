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
    
    convenience init(_ defaultsDictionary: [String: Any], _ controlsPreferences: GesturesControlsPreferences) {
        
        self.init(defaultsDictionary)
        self.controlsPreferences = controlsPreferences
    }
    
    internal required init(_ defaultsDictionary: [String: Any]) {
        
        outputDeviceOnStartup = PreferencesDefaults.Sound.outputDeviceOnStartup
        
        if let outputDeviceOnStartupOptionStr = defaultsDictionary["sound.outputDeviceOnStartup.option"] as? String,
            let option = OutputDeviceStartupOptions(rawValue: outputDeviceOnStartupOptionStr) {
            
            outputDeviceOnStartup.option = option
        }
        
        if let deviceName = defaultsDictionary["sound.outputDeviceOnStartup.preferredDeviceName"] as? String, deviceName.trim() != "" {
            outputDeviceOnStartup.preferredDeviceName = deviceName
        }
        
        if let deviceUID = defaultsDictionary["sound.outputDeviceOnStartup.preferredDeviceUID"] as? String, deviceUID.trim() != "" {
            outputDeviceOnStartup.preferredDeviceUID = deviceUID
        }
        
        volumeDelta = defaultsDictionary["sound.volumeDelta"] as? Float ?? PreferencesDefaults.Sound.volumeDelta
        
        if let volumeOnStartupOptionStr = defaultsDictionary["sound.volumeOnStartup.option"] as? String {
            volumeOnStartupOption = VolumeStartupOptions(rawValue: volumeOnStartupOptionStr) ?? PreferencesDefaults.Sound.volumeOnStartupOption
        } else {
            volumeOnStartupOption = PreferencesDefaults.Sound.volumeOnStartupOption
        }
        
        startupVolumeValue = defaultsDictionary["sound.volumeOnStartup.value"] as? Float ?? PreferencesDefaults.Sound.startupVolumeValue
        
        panDelta = defaultsDictionary["sound.panDelta"] as? Float ?? PreferencesDefaults.Sound.panDelta
        
        eqDelta = defaultsDictionary["sound.eqDelta"] as? Float ?? PreferencesDefaults.Sound.eqDelta
        pitchDelta = defaultsDictionary["sound.pitchDelta"] as? Int ?? PreferencesDefaults.Sound.pitchDelta
        timeDelta = defaultsDictionary["sound.timeDelta"] as? Float ?? PreferencesDefaults.Sound.timeDelta
        
        if let effectsSettingsOnStartupOptionStr = defaultsDictionary["sound.effectsSettingsOnStartup.option"] as? String {
            effectsSettingsOnStartupOption = EffectsSettingsStartupOptions(rawValue: effectsSettingsOnStartupOptionStr) ?? PreferencesDefaults.Sound.effectsSettingsOnStartupOption
        } else {
            effectsSettingsOnStartupOption = PreferencesDefaults.Sound.effectsSettingsOnStartupOption
        }
        
        masterPresetOnStartup_name = defaultsDictionary["sound.effectsSettingsOnStartup.masterPreset"] as? String ?? PreferencesDefaults.Sound.masterPresetOnStartup_name
        
        if let optionStr = defaultsDictionary["sound.rememberEffectsSettings.option"] as? String {
            
            rememberEffectsSettingsOption = RememberSettingsForTrackOptions(rawValue: optionStr) ?? PreferencesDefaults.Sound.rememberEffectsSettingsOption
            
        } else {
            rememberEffectsSettingsOption = PreferencesDefaults.Sound.rememberEffectsSettingsOption
        }
        
        // Revert to default if data is corrupt (missing master preset)
        if effectsSettingsOnStartupOption == .applyMasterPreset && masterPresetOnStartup_name == nil {
            effectsSettingsOnStartupOption = .rememberFromLastAppLaunch
        }
    }
    
    func persist(defaults: UserDefaults) {
        
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
