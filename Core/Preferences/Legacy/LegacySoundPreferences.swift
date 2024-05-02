//
//  LegacySoundPreferences.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class LegacySoundPreferences {
    
    var volumeDelta: Float?
    var panDelta: Float?
    
    var eqDelta: Float?
    var pitchDelta: Int?
    var timeDelta: Float?
    
    var rememberEffectsSettingsOption: LegacyRememberSettingsForTrackOptions?
    
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
    
    internal required init(_ dict: [String: Any]) {
        
        volumeDelta = dict.floatValue(forKey: Self.key_volumeDelta)
        panDelta = dict.floatValue(forKey: Self.key_panDelta)
        
        eqDelta = dict.floatValue(forKey: Self.key_eqDelta)
        pitchDelta = dict.intValue(forKey: Self.key_pitchDelta)
        timeDelta = dict.floatValue(forKey: Self.key_timeDelta)

        rememberEffectsSettingsOption = dict.enumValue(forKey: Self.key_rememberEffectsSettingsOption, ofType: LegacyRememberSettingsForTrackOptions.self)
    }
}

enum LegacyRememberSettingsForTrackOptions: String, CaseIterable {
    
    case allTracks
    case individualTracks
}
