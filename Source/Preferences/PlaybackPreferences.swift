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
    
    var rememberLastPosition: Bool
    var rememberLastPositionOption: RememberSettingsForTrackOptions
    
    // Transcoding preferences
    
    var transcodingPreferences: TranscodingPreferences
    
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
        
        rememberLastPosition = defaultsDictionary["playback.rememberLastPosition"] as? Bool ?? PreferencesDefaults.Playback.rememberLastPosition
        
        if let optionStr = defaultsDictionary["playback.rememberLastPosition.option"] as? String {
            rememberLastPositionOption = RememberSettingsForTrackOptions(rawValue: optionStr) ?? PreferencesDefaults.Playback.rememberLastPositionOption
        } else {
            rememberLastPositionOption = PreferencesDefaults.Playback.rememberLastPositionOption
        }
        
        transcodingPreferences = TranscodingPreferences(defaultsDictionary)
    }
    
    func persist(defaults: UserDefaults) {
        
        defaults.set(primarySeekLengthOption.rawValue, forKey: "playback.seekLength.primary.option")
        defaults.set(primarySeekLengthConstant, forKey: "playback.seekLength.primary.constant")
        defaults.set(primarySeekLengthPercentage, forKey: "playback.seekLength.primary.percentage")
        
        defaults.set(secondarySeekLengthOption.rawValue, forKey: "playback.seekLength.secondary.option")
        defaults.set(secondarySeekLengthConstant, forKey: "playback.seekLength.secondary.constant")
        defaults.set(secondarySeekLengthPercentage, forKey: "playback.seekLength.secondary.percentage")
        
        defaults.set(autoplayOnStartup, forKey: "playback.autoplayOnStartup")
        defaults.set(autoplayAfterAddingTracks, forKey: "playback.autoplayAfterAddingTracks")
        defaults.set(autoplayAfterAddingOption.rawValue, forKey: "playback.autoplayAfterAddingTracks.option")
        
        defaults.set(rememberLastPosition, forKey: "playback.rememberLastPosition")
        defaults.set(rememberLastPositionOption.rawValue, forKey: "playback.rememberLastPosition.option")
        
        transcodingPreferences.persist(defaults: defaults)
    }
}

class TranscodingPreferences {
    
    var persistenceOption: TranscoderPersistenceOptions
    var limitDiskSpaceUsage: Bool
    var maxDiskSpaceUsage: Int // in MB
    
    var eagerTranscodingEnabled: Bool
    var eagerTranscodingOption: EagerTranscodingOptions
    var maxBackgroundTasks: Int
    
    internal required init(_ defaultsDictionary: [String: Any]) {
        
        if let transcoderPersistenceOptionStr = defaultsDictionary["playback.transcoding.persistence.option"] as? String {
            persistenceOption = TranscoderPersistenceOptions(rawValue: transcoderPersistenceOptionStr) ?? PreferencesDefaults.Playback.Transcoding.persistenceOption
        } else {
            persistenceOption = PreferencesDefaults.Playback.Transcoding.persistenceOption
        }
        
        limitDiskSpaceUsage = PreferencesDefaults.Playback.Transcoding.limitDiskSpaceUsage
        maxDiskSpaceUsage = PreferencesDefaults.Playback.Transcoding.maxDiskSpaceUsage
        
        //        limitDiskSpaceUsage = defaultsDictionary["playback.transcoding.persistence.limitDiskSpaceUsage"] as? Bool ?? PreferencesDefaults.Playback.Transcoding.limitDiskSpaceUsage
        //        maxDiskSpaceUsage = defaultsDictionary["playback.transcoding.persistence.maxDiskSpaceUsage"] as? Int ?? PreferencesDefaults.Playback.Transcoding.maxDiskSpaceUsage
        
        eagerTranscodingEnabled = PreferencesDefaults.Playback.Transcoding.eagerTranscodingEnabled
        
        //        if let eagerTranscodingOptionStr = defaultsDictionary["playback.transcoding.eagerTranscoding.option"] as? String {
        //            eagerTranscodingOption = EagerTranscodingOptions(rawValue: eagerTranscodingOptionStr) ?? PreferencesDefaults.Playback.Transcoding.eagerTranscodingOption
        //        } else {
        //            eagerTranscodingOption = PreferencesDefaults.Playback.Transcoding.eagerTranscodingOption
        //        }
        
        eagerTranscodingOption = PreferencesDefaults.Playback.Transcoding.eagerTranscodingOption
        
        //        maxBackgroundTasks = defaultsDictionary["playback.transcoding.maxBackgroundTasks"] as? Int ?? PreferencesDefaults.Playback.Transcoding.maxBackgroundTasks
        maxBackgroundTasks = PreferencesDefaults.Playback.Transcoding.maxBackgroundTasks
    }
    
    func persist(defaults: UserDefaults) {
        
        defaults.set(persistenceOption.rawValue, forKey: "playback.transcoding.persistence.option")
        //        defaults.set(limitDiskSpaceUsage, forKey: "playback.transcoding.persistence.limitDiskSpaceUsage")
        //        defaults.set(maxDiskSpaceUsage, forKey: "playback.transcoding.persistence.maxDiskSpaceUsage")
        //
        //        defaults.set(eagerTranscodingEnabled, forKey: "playback.transcoding.eagerTranscoding.enabled")
        //        defaults.set(eagerTranscodingOption.rawValue, forKey: "playback.transcoding.eagerTranscoding.option")
        //
        //        defaults.set(maxBackgroundTasks, forKey: "playback.transcoding.maxBackgroundTasks")
    }
}
