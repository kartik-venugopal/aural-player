import Foundation

class RemoteControlPreferences: PersistentPreferencesProtocol {
    
    var enabled: Bool
    var trackChangeOrSeekingOption: TrackChangeOrSeekingOptions
    
    private static let keyPrefix: String = "controls.remoteControl"
    
    private static let key_enabled: String = "\(keyPrefix).enabled"
    private static let key_trackChangeOrSeekingOption: String = "\(keyPrefix).trackChangeOrSeekingOption"
    
    private typealias Defaults = PreferencesDefaults.Controls.RemoteControl
    
    internal required init(_ dict: [String: Any]) {

        enabled = dict[Self.key_enabled, Bool.self] ?? Defaults.enabled
        
        trackChangeOrSeekingOption = dict.enumValue(forKey: Self.key_trackChangeOrSeekingOption, ofType: TrackChangeOrSeekingOptions.self) ?? Defaults.trackChangeOrSeekingOption
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults.set(enabled, forKey: Self.key_enabled)
        defaults.set(trackChangeOrSeekingOption.rawValue, forKey: Self.key_trackChangeOrSeekingOption)
    }
}
