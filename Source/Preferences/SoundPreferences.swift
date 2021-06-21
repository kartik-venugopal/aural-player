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
        
        volumeDelta = dict[Self.key_volumeDelta, Float.self] ?? Defaults.volumeDelta
        
        volumeOnStartupOption = dict.enumValue(forKey: Self.key_volumeOnStartupOption, ofType: VolumeStartupOptions.self) ?? Defaults.volumeOnStartupOption
        
        startupVolumeValue = dict[Self.key_volumeOnStartupOption, Float.self] ?? Defaults.startupVolumeValue
        
        panDelta = dict[Self.key_panDelta, Float.self] ?? Defaults.panDelta
        
        eqDelta = dict[Self.key_eqDelta, Float.self] ?? Defaults.eqDelta
        pitchDelta = dict[Self.key_pitchDelta, Int.self] ?? Defaults.pitchDelta
        timeDelta = dict[Self.key_timeDelta, Float.self] ?? Defaults.timeDelta
        
        effectsSettingsOnStartupOption = dict.enumValue(forKey: Self.key_effectsSettingsOnStartupOption, ofType: EffectsSettingsStartupOptions.self) ?? Defaults.effectsSettingsOnStartupOption
        
        masterPresetOnStartup_name = dict[Self.key_masterPresetOnStartup_name, String.self] ?? Defaults.masterPresetOnStartup_name
        
        rememberEffectsSettingsOption = dict.enumValue(forKey: Self.key_rememberEffectsSettingsOption, ofType: RememberSettingsForTrackOptions.self) ?? Defaults.rememberEffectsSettingsOption
        
        // Revert to default if data is corrupt (missing master preset)
        if effectsSettingsOnStartupOption == .applyMasterPreset && masterPresetOnStartup_name == nil {
            effectsSettingsOnStartupOption = .rememberFromLastAppLaunch
        }
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults.set(outputDeviceOnStartup.option.rawValue, forKey: Self.key_outputDeviceOnStartupOption)
        defaults.set(outputDeviceOnStartup.preferredDeviceName, forKey: Self.key_outputDeviceOnStartupPreferredDeviceName)
        defaults.set(outputDeviceOnStartup.preferredDeviceUID, forKey: Self.key_outputDeviceOnStartupPreferredDeviceUID)
        
        defaults.set(volumeDelta, forKey: Self.key_volumeDelta)
        
        defaults.set(volumeOnStartupOption.rawValue, forKey: Self.key_volumeOnStartupOption)
        defaults.set(startupVolumeValue, forKey: Self.key_startupVolumeValue)
        
        defaults.set(panDelta, forKey: Self.key_panDelta)
        
        defaults.set(eqDelta, forKey: Self.key_eqDelta)
        defaults.set(pitchDelta, forKey: Self.key_pitchDelta)
        defaults.set(timeDelta, forKey: Self.key_timeDelta)
        
        defaults.set(effectsSettingsOnStartupOption.rawValue, forKey: Self.key_effectsSettingsOnStartupOption)
        defaults.set(masterPresetOnStartup_name, forKey: Self.key_masterPresetOnStartup_name)
        
        defaults.set(rememberEffectsSettingsOption.rawValue, forKey: Self.key_rememberEffectsSettingsOption)
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
