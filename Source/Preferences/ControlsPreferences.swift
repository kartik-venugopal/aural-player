import Cocoa

class ControlsPreferences: PersistentPreferencesProtocol {
    
    var respondToMediaKeys: Bool
    var skipKeyBehavior: SkipKeyBehavior
    var repeatSpeed: SkipKeyRepeatSpeed
    
    var allowVolumeControl: Bool
    var allowSeeking: Bool
    var allowTrackChange: Bool
    
    var allowPlaylistNavigation: Bool
    var allowPlaylistTabToggle: Bool
    
    var volumeControlSensitivity: ScrollSensitivity
    var seekSensitivity: ScrollSensitivity
    
    internal required init(_ defaultsDictionary: [String: Any]) {
        
        // Media keys
        
        respondToMediaKeys = defaultsDictionary["controls.respondToMediaKeys"] as? Bool ?? PreferencesDefaults.Controls.respondToMediaKeys
        
        if let skipKeyBehaviorStr = defaultsDictionary["controls.skipKeyBehavior"] as? String {
            skipKeyBehavior = SkipKeyBehavior(rawValue: skipKeyBehaviorStr) ?? PreferencesDefaults.Controls.skipKeyBehavior
        } else {
            skipKeyBehavior = PreferencesDefaults.Controls.skipKeyBehavior
        }
        
        if let repeatSpeedStr = defaultsDictionary["controls.repeatSpeed"] as? String {
            repeatSpeed = SkipKeyRepeatSpeed(rawValue: repeatSpeedStr) ?? PreferencesDefaults.Controls.repeatSpeed
        } else {
            repeatSpeed = PreferencesDefaults.Controls.repeatSpeed
        }
        
        // Gestures
        
        allowVolumeControl = defaultsDictionary["controls.allowVolumeControl"] as? Bool ?? PreferencesDefaults.Controls.allowVolumeControl
        
        allowSeeking = defaultsDictionary["controls.allowSeeking"] as? Bool ?? PreferencesDefaults.Controls.allowSeeking
        
        allowTrackChange = defaultsDictionary["controls.allowTrackChange"] as? Bool ?? PreferencesDefaults.Controls.allowTrackChange
        
        allowPlaylistNavigation = defaultsDictionary["controls.allowPlaylistNavigation"] as? Bool ?? PreferencesDefaults.Controls.allowPlaylistNavigation
        
        allowPlaylistTabToggle = defaultsDictionary["controls.allowPlaylistTabToggle"] as? Bool ?? PreferencesDefaults.Controls.allowPlaylistTabToggle
        
        if let volumeControlSensitivityStr = defaultsDictionary["controls.volumeControlSensitivity"] as? String {
            volumeControlSensitivity = ScrollSensitivity(rawValue: volumeControlSensitivityStr)!
        } else {
            volumeControlSensitivity = PreferencesDefaults.Controls.volumeControlSensitivity
        }
        
        if let seekSensitivityStr = defaultsDictionary["controls.seekSensitivity"] as? String {
            seekSensitivity = ScrollSensitivity(rawValue: seekSensitivityStr)!
        } else {
            seekSensitivity = PreferencesDefaults.Controls.seekSensitivity
        }
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults.set(respondToMediaKeys, forKey: "controls.respondToMediaKeys")
        defaults.set(skipKeyBehavior.rawValue, forKey: "controls.skipKeyBehavior")
        defaults.set(repeatSpeed.rawValue, forKey: "controls.repeatSpeed")
        
        defaults.set(allowVolumeControl, forKey: "controls.allowVolumeControl")
        defaults.set(allowSeeking, forKey: "controls.allowSeeking")
        defaults.set(allowTrackChange, forKey: "controls.allowTrackChange")
        
        defaults.set(allowPlaylistNavigation, forKey: "controls.allowPlaylistNavigation")
        defaults.set(allowPlaylistTabToggle, forKey: "controls.allowPlaylistTabToggle")
        
        defaults.set(volumeControlSensitivity.rawValue, forKey: "controls.volumeControlSensitivity")
        defaults.set(seekSensitivity.rawValue, forKey: "controls.seekSensitivity")
    }
}
