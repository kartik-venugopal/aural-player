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
    
    private var controlsPreferences: ControlsPreferences!
    
    var autoplayOnStartup: Bool
    var autoplayAfterAddingTracks: Bool
    var autoplayAfterAddingOption: AutoplayAfterAddingOptions
    
    var rememberLastPositionOption: RememberSettingsForTrackOptions
    
    convenience init(_ defaultsDictionary: [String: Any], _ controlsPreferences: ControlsPreferences) {
        self.init(defaultsDictionary)
        self.controlsPreferences = controlsPreferences
    }
    
    internal required init(_ defaultsDictionary: [String: Any]) {
        
        if let primarySeekLengthOptionStr = defaultsDictionary["playback.seekLength.primary.option"] as? String {
            primarySeekLengthOption = SeekLengthOptions(rawValue: primarySeekLengthOptionStr) ?? PreferencesDefaults.Playback.primarySeekLengthOption
        } else {
            primarySeekLengthOption = PreferencesDefaults.Playback.primarySeekLengthOption
        }
        
        primarySeekLengthConstant = defaultsDictionary["playback.seekLength.primary.constant"] as? Int ?? PreferencesDefaults.Playback.primarySeekLengthConstant
        primarySeekLengthPercentage = defaultsDictionary["playback.seekLength.primary.percentage"] as? Int ?? PreferencesDefaults.Playback.primarySeekLengthPercentage
        
        if let secondarySeekLengthOptionStr = defaultsDictionary["playback.seekLength.secondary.option"] as? String {
            secondarySeekLengthOption = SeekLengthOptions(rawValue: secondarySeekLengthOptionStr) ?? PreferencesDefaults.Playback.secondarySeekLengthOption
        } else {
            secondarySeekLengthOption = PreferencesDefaults.Playback.secondarySeekLengthOption
        }
        
        secondarySeekLengthConstant = defaultsDictionary["playback.seekLength.secondary.constant"] as? Int ?? PreferencesDefaults.Playback.secondarySeekLengthConstant
        secondarySeekLengthPercentage = defaultsDictionary["playback.seekLength.secondary.percentage"] as? Int ?? PreferencesDefaults.Playback.secondarySeekLengthPercentage
        
        autoplayOnStartup = defaultsDictionary["playback.autoplayOnStartup"] as? Bool ?? PreferencesDefaults.Playback.autoplayOnStartup
        
        autoplayAfterAddingTracks = defaultsDictionary["playback.autoplayAfterAddingTracks"] as? Bool ?? PreferencesDefaults.Playback.autoplayAfterAddingTracks
        
        if let autoplayAfterAddingOptionStr = defaultsDictionary["playback.autoplayAfterAddingTracks.option"] as? String {
            autoplayAfterAddingOption = AutoplayAfterAddingOptions(rawValue: autoplayAfterAddingOptionStr) ?? PreferencesDefaults.Playback.autoplayAfterAddingOption
        } else {
            autoplayAfterAddingOption = PreferencesDefaults.Playback.autoplayAfterAddingOption
        }
        
        if let optionStr = defaultsDictionary["playback.rememberLastPosition.option"] as? String {
            rememberLastPositionOption = RememberSettingsForTrackOptions(rawValue: optionStr) ?? PreferencesDefaults.Playback.rememberLastPositionOption
        } else {
            rememberLastPositionOption = PreferencesDefaults.Playback.rememberLastPositionOption
        }
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults.set(primarySeekLengthOption.rawValue, forKey: "playback.seekLength.primary.option")
        defaults.set(primarySeekLengthConstant, forKey: "playback.seekLength.primary.constant")
        defaults.set(primarySeekLengthPercentage, forKey: "playback.seekLength.primary.percentage")
        
        defaults.set(secondarySeekLengthOption.rawValue, forKey: "playback.seekLength.secondary.option")
        defaults.set(secondarySeekLengthConstant, forKey: "playback.seekLength.secondary.constant")
        defaults.set(secondarySeekLengthPercentage, forKey: "playback.seekLength.secondary.percentage")
        
        defaults.set(autoplayOnStartup, forKey: "playback.autoplayOnStartup")
        defaults.set(autoplayAfterAddingTracks, forKey: "playback.autoplayAfterAddingTracks")
        defaults.set(autoplayAfterAddingOption.rawValue, forKey: "playback.autoplayAfterAddingTracks.option")
        
        defaults.set(rememberLastPositionOption.rawValue, forKey: "playback.rememberLastPosition.option")
    }
}
