import Foundation

class MediaKeysControlsPreferences: PersistentPreferencesProtocol {
    
    var enabled: Bool
    var skipKeyBehavior: SkipKeyBehavior
    var repeatSpeed: SkipKeyRepeatSpeed
    
    private static let keyPrefix: String = "controls.mediaKeys"
    
    private static let key_enabled: String = "\(keyPrefix).enabled"
    private static let key_skipKeyBehavior: String = "\(keyPrefix).skipKeyBehavior"
    private static let key_repeatSpeed: String = "\(keyPrefix).repeatSpeed"
    
    private typealias Defaults = PreferencesDefaults.Controls.MediaKeys
    
    internal required init(_ dict: [String: Any]) {
        
        enabled = dict[Self.key_enabled, Bool.self] ?? Defaults.enabled
        skipKeyBehavior = dict.enumValue(forKey: Self.key_skipKeyBehavior, ofType: SkipKeyBehavior.self) ?? Defaults.skipKeyBehavior
        repeatSpeed = dict.enumValue(forKey: Self.key_repeatSpeed, ofType: SkipKeyRepeatSpeed.self) ?? Defaults.repeatSpeed
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults[Self.key_enabled] = enabled
        defaults[Self.key_skipKeyBehavior] = skipKeyBehavior.rawValue
        defaults[Self.key_repeatSpeed] = repeatSpeed.rawValue
    }
}

enum SkipKeyBehavior: String {
    
    case hybrid
    case trackChangesOnly
    case seekingOnly
}

enum SkipKeyRepeatSpeed: String {
    
    case slow
    case medium
    case fast
}
