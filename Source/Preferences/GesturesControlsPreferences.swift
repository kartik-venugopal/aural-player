import Foundation

class GesturesControlsPreferences: PersistentPreferencesProtocol {
    
    var allowVolumeControl: Bool
    var allowSeeking: Bool
    var allowTrackChange: Bool
    
    var allowPlaylistNavigation: Bool
    var allowPlaylistTabToggle: Bool
    
    var volumeControlSensitivity: ScrollSensitivity
    var seekSensitivity: ScrollSensitivity
    
    private static let keyPrefix: String = "controls.gestures"
    
    private static let key_allowVolumeControl: String = "\(keyPrefix).allowVolumeControl"
    private static let key_allowSeeking: String = "\(keyPrefix).allowSeeking"
    private static let key_allowTrackChange: String = "\(keyPrefix).allowTrackChange"
    
    private static let key_allowPlaylistNavigation: String = "\(keyPrefix).allowPlaylistNavigation"
    private static let key_allowPlaylistTabToggle: String = "\(keyPrefix).allowPlaylistTabToggle"
    
    private static let key_volumeControlSensitivity: String = "\(keyPrefix).volumeControlSensitivity"
    private static let key_seekSensitivity: String = "\(keyPrefix).seekSensitivity"
    
    private typealias Defaults = PreferencesDefaults.Controls.Gestures
    
    internal required init(_ dict: [String: Any]) {
        
        allowVolumeControl = dict[Self.key_allowVolumeControl, Bool.self] ?? Defaults.allowVolumeControl
        
        allowSeeking = dict[Self.key_allowSeeking, Bool.self] ?? Defaults.allowSeeking
        
        allowTrackChange = dict[Self.key_allowTrackChange, Bool.self] ?? Defaults.allowTrackChange
        
        allowPlaylistNavigation = dict[Self.key_allowPlaylistNavigation, Bool.self] ?? Defaults.allowPlaylistNavigation
        
        allowPlaylistTabToggle = dict[Self.key_allowPlaylistTabToggle, Bool.self] ?? Defaults.allowPlaylistTabToggle
        
        volumeControlSensitivity = dict.enumValue(forKey: Self.key_volumeControlSensitivity, ofType: ScrollSensitivity.self) ??  Defaults.volumeControlSensitivity
        
        seekSensitivity = dict.enumValue(forKey: Self.key_seekSensitivity, ofType: ScrollSensitivity.self) ?? Defaults.seekSensitivity
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults.set(allowVolumeControl, forKey: Self.key_allowVolumeControl)
        defaults.set(allowSeeking, forKey: Self.key_allowSeeking)
        defaults.set(allowTrackChange, forKey: Self.key_allowTrackChange)
        
        defaults.set(allowPlaylistNavigation, forKey: Self.key_allowPlaylistNavigation)
        defaults.set(allowPlaylistTabToggle, forKey: Self.key_allowPlaylistTabToggle)
        
        defaults.set(volumeControlSensitivity.rawValue, forKey: Self.key_volumeControlSensitivity)
        defaults.set(seekSensitivity.rawValue, forKey: Self.key_seekSensitivity)
    }
}
