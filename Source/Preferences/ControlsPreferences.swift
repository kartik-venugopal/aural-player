import Cocoa

class ControlsPreferences: PersistentPreferencesProtocol {
    
    var mediaKeys: MediaKeysControlsPreferences
    var gestures: GesturesControlsPreferences
    var remoteControl: RemoteControlPreferences
    
    internal required init(_ dict: [String: Any]) {
        
        mediaKeys = MediaKeysControlsPreferences(defaults)
        gestures = GesturesControlsPreferences(defaults)
        remoteControl = RemoteControlPreferences(defaults)
    }
    
    func persist(to defaults: UserDefaults) {
        
        mediaKeys.persist(to: defaults)
        gestures.persist(to: defaults)
        remoteControl.persist(to: defaults)
    }
}

class MediaKeysControlsPreferences: PersistentPreferencesProtocol {
    
    var enabled: Bool
    var skipKeyBehavior: SkipKeyBehavior
    var repeatSpeed: SkipKeyRepeatSpeed
    
    internal required init(_ dict: [String: Any]) {
        
        // Media keys
        
        enabled = defaults["controls.mediaKeys.enabled", Bool.self] ?? PreferencesDefaults.Controls.MediaKeys.enabled
        
        if let skipKeyBehaviorStr = defaults["controls.mediaKeys.skipKeyBehavior", String.self] {
            skipKeyBehavior = SkipKeyBehavior(rawValue: skipKeyBehaviorStr) ?? PreferencesDefaults.Controls.MediaKeys.skipKeyBehavior
        } else {
            skipKeyBehavior = PreferencesDefaults.Controls.MediaKeys.skipKeyBehavior
        }
        
        if let repeatSpeedStr = defaults["controls.mediaKeys.repeatSpeed", String.self] {
            repeatSpeed = SkipKeyRepeatSpeed(rawValue: repeatSpeedStr) ?? PreferencesDefaults.Controls.MediaKeys.repeatSpeed
        } else {
            repeatSpeed = PreferencesDefaults.Controls.MediaKeys.repeatSpeed
        }
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults.set(enabled, forKey: "controls.mediaKeys.enabled")
        defaults.set(skipKeyBehavior.rawValue, forKey: "controls.mediaKeys.skipKeyBehavior")
        defaults.set(repeatSpeed.rawValue, forKey: "controls.mediaKeys.repeatSpeed")
    }
}

class GesturesControlsPreferences: PersistentPreferencesProtocol {
    
    var allowVolumeControl: Bool
    var allowSeeking: Bool
    var allowTrackChange: Bool
    
    var allowPlaylistNavigation: Bool
    var allowPlaylistTabToggle: Bool
    
    var volumeControlSensitivity: ScrollSensitivity
    var seekSensitivity: ScrollSensitivity
    
    internal required init(_ dict: [String: Any]) {
        
        // Gestures
        
        allowVolumeControl = defaults["controls.gestures.allowVolumeControl", Bool.self] ?? PreferencesDefaults.Controls.Gestures.allowVolumeControl
        
        allowSeeking = defaults["controls.gestures.allowSeeking", Bool.self] ?? PreferencesDefaults.Controls.Gestures.allowSeeking
        
        allowTrackChange = defaults["controls.gestures.allowTrackChange", Bool.self] ?? PreferencesDefaults.Controls.Gestures.allowTrackChange
        
        allowPlaylistNavigation = defaults["controls.gestures.allowPlaylistNavigation", Bool.self] ?? PreferencesDefaults.Controls.Gestures.allowPlaylistNavigation
        
        allowPlaylistTabToggle = defaults["controls.gestures.allowPlaylistTabToggle", Bool.self] ?? PreferencesDefaults.Controls.Gestures.allowPlaylistTabToggle
        
        if let volumeControlSensitivityStr = defaults["controls.gestures.volumeControlSensitivity", String.self] {
            volumeControlSensitivity = ScrollSensitivity(rawValue: volumeControlSensitivityStr)!
        } else {
            volumeControlSensitivity = PreferencesDefaults.Controls.Gestures.volumeControlSensitivity
        }
        
        if let seekSensitivityStr = defaults["controls.gestures.seekSensitivity", String.self] {
            seekSensitivity = ScrollSensitivity(rawValue: seekSensitivityStr)!
        } else {
            seekSensitivity = PreferencesDefaults.Controls.Gestures.seekSensitivity
        }
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults.set(allowVolumeControl, forKey: "controls.gestures.allowVolumeControl")
        defaults.set(allowSeeking, forKey: "controls.gestures.allowSeeking")
        defaults.set(allowTrackChange, forKey: "controls.gestures.allowTrackChange")
        
        defaults.set(allowPlaylistNavigation, forKey: "controls.gestures.allowPlaylistNavigation")
        defaults.set(allowPlaylistTabToggle, forKey: "controls.gestures.allowPlaylistTabToggle")
        
        defaults.set(volumeControlSensitivity.rawValue, forKey: "controls.gestures.volumeControlSensitivity")
        defaults.set(seekSensitivity.rawValue, forKey: "controls.gestures.seekSensitivity")
    }
}

class RemoteControlPreferences: PersistentPreferencesProtocol {
    
    var enabled: Bool
    var trackChangeOrSeekingOption: TrackChangeOrSeekingOptions
    
    internal required init(_ dict: [String: Any]) {

        enabled = defaults["controls.remoteControl.enabled", Bool.self] ?? PreferencesDefaults.Controls.RemoteControl.enabled
        
        if let trackChangeOrSeekingOptionStr = defaults["controls.remoteControl.trackChangeOrSeekingOption", String.self] {
            
            trackChangeOrSeekingOption = TrackChangeOrSeekingOptions(rawValue: trackChangeOrSeekingOptionStr) ?? PreferencesDefaults.Controls.RemoteControl.trackChangeOrSeekingOption
        } else {
            trackChangeOrSeekingOption = PreferencesDefaults.Controls.RemoteControl.trackChangeOrSeekingOption
        }
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults.set(enabled, forKey: "controls.remoteControl.enabled")
        defaults.set(trackChangeOrSeekingOption.rawValue, forKey: "controls.remoteControl.trackChangeOrSeekingOption")
    }
}
