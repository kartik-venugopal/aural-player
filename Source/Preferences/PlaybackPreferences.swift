//
//  PlaybackPreferences.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// Encapsulates all user preferences pertaining to track playback.
///
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
    
    static let key_primarySeekLengthOption: String = "\(keyPrefix).seekLength.primary.option"
    static let key_primarySeekLengthConstant: String = "\(keyPrefix).seekLength.primary.constant"
    static let key_primarySeekLengthPercentage: String = "\(keyPrefix).seekLength.primary.percentage"
    
    static let key_secondarySeekLengthOption: String = "\(keyPrefix).seekLength.secondary.option"
    static let key_secondarySeekLengthConstant: String = "\(keyPrefix).seekLength.secondary.constant"
    static let key_secondarySeekLengthPercentage: String = "\(keyPrefix).seekLength.secondary.percentage"
    
    static let key_autoplayOnStartup: String = "\(keyPrefix).autoplayOnStartup"
    static let key_autoplayAfterAddingTracks: String = "\(keyPrefix).autoplayAfterAddingTracks"
    static let key_autoplayAfterAddingOption: String = "\(keyPrefix).autoplayAfterAddingTracks.option"
    
    static let key_rememberLastPositionOption: String = "\(keyPrefix).rememberLastPosition.option"
    
    convenience init(_ dict: [String: Any], _ controlsPreferences: GesturesControlsPreferences) {
        
        self.init(dict)
        self.controlsPreferences = controlsPreferences
    }
    
    private typealias Defaults = PreferencesDefaults.Playback
    
    internal required init(_ dict: [String: Any]) {
        
        primarySeekLengthOption = dict.enumValue(forKey: Self.key_primarySeekLengthOption,
                                                 ofType: SeekLengthOptions.self) ?? Defaults.primarySeekLengthOption
        
        primarySeekLengthConstant = dict.intValue(forKey: Self.key_primarySeekLengthConstant) ?? Defaults.primarySeekLengthConstant
        primarySeekLengthPercentage = dict.intValue(forKey: Self.key_primarySeekLengthPercentage) ?? Defaults.primarySeekLengthPercentage
        
        secondarySeekLengthOption = dict.enumValue(forKey: Self.key_secondarySeekLengthOption,
                                                   ofType: SeekLengthOptions.self) ?? Defaults.secondarySeekLengthOption
        
        secondarySeekLengthConstant = dict.intValue(forKey: Self.key_secondarySeekLengthConstant) ?? Defaults.secondarySeekLengthConstant
        secondarySeekLengthPercentage = dict.intValue(forKey: Self.key_secondarySeekLengthPercentage) ?? Defaults.secondarySeekLengthPercentage
        
        autoplayOnStartup = dict[Self.key_autoplayOnStartup, Bool.self] ?? Defaults.autoplayOnStartup
        
        autoplayAfterAddingTracks = dict[Self.key_autoplayAfterAddingTracks, Bool.self] ?? Defaults.autoplayAfterAddingTracks
        
        autoplayAfterAddingOption = dict.enumValue(forKey: Self.key_autoplayAfterAddingOption,
                                                   ofType: AutoplayAfterAddingOptions.self) ?? Defaults.autoplayAfterAddingOption
        
        rememberLastPositionOption = dict.enumValue(forKey: Self.key_rememberLastPositionOption,
                                                    ofType: RememberSettingsForTrackOptions.self) ?? Defaults.rememberLastPositionOption
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults[Self.key_primarySeekLengthOption] = primarySeekLengthOption.rawValue 
        defaults[Self.key_primarySeekLengthConstant] = primarySeekLengthConstant 
        defaults[Self.key_primarySeekLengthPercentage] = primarySeekLengthPercentage 
        
        defaults[Self.key_secondarySeekLengthOption] = secondarySeekLengthOption.rawValue 
        defaults[Self.key_secondarySeekLengthConstant] = secondarySeekLengthConstant 
        defaults[Self.key_secondarySeekLengthPercentage] = secondarySeekLengthPercentage 
        
        defaults[Self.key_autoplayOnStartup] = autoplayOnStartup 
        defaults[Self.key_autoplayAfterAddingTracks] = autoplayAfterAddingTracks 
        defaults[Self.key_autoplayAfterAddingOption] = autoplayAfterAddingOption.rawValue 
        
        defaults[Self.key_rememberLastPositionOption] = rememberLastPositionOption.rawValue 
    }
}

enum SeekLengthOptions: String, CaseIterable {
    
    case constant
    case percentage
}

// Possible options for the "autoplay afer adding tracks" user preference
enum AutoplayAfterAddingOptions: String, CaseIterable {
    
    case ifNotPlaying
    case always
}

enum RememberSettingsForTrackOptions: String, CaseIterable {
    
    case allTracks
    case individualTracks
}
