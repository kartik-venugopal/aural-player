import Cocoa

class PlaybackPreferences: PersistentPreferencesProtocol {
    
    // General preferences
    
    var primarySeekLengthOption: SeekLengthOptions
    var primarySeekLengthConstant: Int
    var primarySeekLengthPercentage: Int
    
    var secondarySeekLengthOption: SeekLengthOptions
    var secondarySeekLengthConstant: Int
    var secondarySeekLengthPercentage: Int
    
    private let scrollSensitiveSeekLengths: [ScrollSensitivity: Double] = [.low: 2.5, .medium: 5, .high: 10]
    var seekLength_continuous: Double {
        return scrollSensitiveSeekLengths[controlsPreferences.seekSensitivity]!
    }
    
    private var controlsPreferences: GesturesControlsPreferences!
    
    var autoplayOnStartup: Bool
    var autoplayAfterAddingTracks: Bool
    var autoplayAfterAddingOption: AutoplayAfterAddingOptions
    
    var rememberLastPositionOption: RememberSettingsForTrackOptions
    
    private static let keyPrefix: String = "playback"
    
    private static let key_primarySeekLengthOption: String = "\(keyPrefix).seekLength.primary.option"
    private static let key_primarySeekLengthConstant: String = "\(keyPrefix).seekLength.primary.constant"
    private static let key_primarySeekLengthPercentage: String = "\(keyPrefix).seekLength.primary.percentage"
    
    private static let key_secondarySeekLengthOption: String = "\(keyPrefix).seekLength.secondary.option"
    private static let key_secondarySeekLengthConstant: String = "\(keyPrefix).seekLength.secondary.constant"
    private static let key_secondarySeekLengthPercentage: String = "\(keyPrefix).seekLength.secondary.percentage"
    
    private static let key_autoplayOnStartup: String = "\(keyPrefix).autoplayOnStartup"
    private static let key_autoplayAfterAddingTracks: String = "\(keyPrefix).autoplayAfterAddingTracks"
    private static let key_autoplayAfterAddingOption: String = "\(keyPrefix).autoplayAfterAddingTracks.option"
    
    private static let key_rememberLastPositionOption: String = "\(keyPrefix).rememberLastPosition.option"
    
    convenience init(_ dict: [String: Any], _ controlsPreferences: GesturesControlsPreferences) {
        
        self.init(dict)
        self.controlsPreferences = controlsPreferences
    }
    
    private typealias Defaults = PreferencesDefaults.Playback
    
    internal required init(_ dict: [String: Any]) {
        
        primarySeekLengthOption = dict.enumValue(forKey: Self.key_primarySeekLengthOption,
                                                 ofType: SeekLengthOptions.self) ?? Defaults.primarySeekLengthOption
        
        primarySeekLengthConstant = dict[Self.key_primarySeekLengthConstant, Int.self] ?? Defaults.primarySeekLengthConstant
        primarySeekLengthPercentage = dict[Self.key_primarySeekLengthPercentage, Int.self] ?? Defaults.primarySeekLengthPercentage
        
        secondarySeekLengthOption = dict.enumValue(forKey: Self.key_secondarySeekLengthOption,
                                                   ofType: SeekLengthOptions.self) ?? Defaults.secondarySeekLengthOption
        
        secondarySeekLengthConstant = dict[Self.key_secondarySeekLengthConstant, Int.self] ?? Defaults.secondarySeekLengthConstant
        secondarySeekLengthPercentage = dict[Self.key_secondarySeekLengthPercentage, Int.self] ?? Defaults.secondarySeekLengthPercentage
        
        autoplayOnStartup = dict[Self.key_autoplayOnStartup, Bool.self] ?? Defaults.autoplayOnStartup
        
        autoplayAfterAddingTracks = dict[Self.key_autoplayAfterAddingTracks, Bool.self] ?? Defaults.autoplayAfterAddingTracks
        
        autoplayAfterAddingOption = dict.enumValue(forKey: Self.key_autoplayAfterAddingOption,
                                                   ofType: AutoplayAfterAddingOptions.self) ?? Defaults.autoplayAfterAddingOption
        
        rememberLastPositionOption = dict.enumValue(forKey: Self.key_rememberLastPositionOption,
                                                    ofType: RememberSettingsForTrackOptions.self) ?? Defaults.rememberLastPositionOption
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults.set(primarySeekLengthOption.rawValue, forKey: Self.key_primarySeekLengthOption)
        defaults.set(primarySeekLengthConstant, forKey: Self.key_primarySeekLengthConstant)
        defaults.set(primarySeekLengthPercentage, forKey: Self.key_primarySeekLengthPercentage)
        
        defaults.set(secondarySeekLengthOption.rawValue, forKey: Self.key_secondarySeekLengthOption)
        defaults.set(secondarySeekLengthConstant, forKey: Self.key_secondarySeekLengthConstant)
        defaults.set(secondarySeekLengthPercentage, forKey: Self.key_secondarySeekLengthPercentage)
        
        defaults.set(autoplayOnStartup, forKey: Self.key_autoplayOnStartup)
        defaults.set(autoplayAfterAddingTracks, forKey: Self.key_autoplayAfterAddingTracks)
        defaults.set(autoplayAfterAddingOption.rawValue, forKey: Self.key_autoplayAfterAddingOption)
        
        defaults.set(rememberLastPositionOption.rawValue, forKey: Self.key_rememberLastPositionOption)
    }
}
