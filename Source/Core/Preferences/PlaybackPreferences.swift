//
//  PlaybackPreferences.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// Encapsulates all user preferences pertaining to track playback.
///
class PlaybackPreferences {
    
    private static let keyPrefix: String = "playback"
    
    private typealias Defaults = PreferencesDefaults.Playback
    
    private let controlsPreferences: GesturesControlsPreferences
    
    init(controlsPreferences: GesturesControlsPreferences, legacyPreferences: LegacyPlaybackPreferences? = nil) {
        
        self.controlsPreferences = controlsPreferences
        
        guard let legacyPreferences = legacyPreferences else {return}
        
        if let rememberLastPositionOption = legacyPreferences.rememberLastPositionOption {
            self.rememberLastPositionForAllTracks.value = rememberLastPositionOption == .allTracks
        }
        
        legacyPreferences.deleteAll()
    }
    
    // General preferences
    
    lazy var primarySeekLengthOption: UserPreference<SeekLengthOption> = .init(defaultsKey: "\(Self.keyPrefix).seekLength.primary.option",
                                                                               defaultValue: Defaults.primarySeekLengthOption)
    
    lazy var primarySeekLengthConstant: UserPreference<Int> = .init(defaultsKey: "\(Self.keyPrefix).seekLength.primary.constant",
                                                                    defaultValue: Defaults.primarySeekLengthConstant)
    
    lazy var primarySeekLengthPercentage: UserPreference<Int> = .init(defaultsKey: "\(Self.keyPrefix).seekLength.primary.percentage",
                                                                      defaultValue: Defaults.primarySeekLengthPercentage)
    
    lazy var secondarySeekLengthOption: UserPreference<SeekLengthOption> = .init(defaultsKey: "\(Self.keyPrefix).seekLength.secondary.option",
                                                                                 defaultValue: Defaults.secondarySeekLengthOption)
    
    lazy var secondarySeekLengthConstant: UserPreference<Int> = .init(defaultsKey: "\(Self.keyPrefix).seekLength.secondary.constant",
                                                                      defaultValue: Defaults.secondarySeekLengthConstant)
    
    lazy var secondarySeekLengthPercentage: UserPreference<Int> = .init(defaultsKey: "\(Self.keyPrefix).seekLength.secondary.percentage",
                                                                        defaultValue: Defaults.secondarySeekLengthConstant)
    
    var seekLength_continuous: Double {
        
        switch controlsPreferences.seekSensitivity.value {
            
        case .low:
            return 2.5
            
        case .medium:
            return 5
            
        case .high:
            return 10
        }
    }
    
    lazy var autoplayOnStartup: UserPreference<Bool> = .init(defaultsKey: "\(Self.keyPrefix).autoplay.onStartup",
                                                             defaultValue: Defaults.autoplayOnStartup)
    
    lazy var autoplayOnStartupOption: UserPreference<AutoplayOnStartupOption> = .init(defaultsKey: "\(Self.keyPrefix).autoplay.onStartup.option",
                                                             defaultValue: Defaults.autoplayOnStartupOption)
    
    lazy var autoplayAfterAddingTracks: UserPreference<Bool> = .init(defaultsKey: "\(Self.keyPrefix).autoplay.afterAddingTracks",
                                                                     defaultValue: Defaults.autoplayAfterAddingTracks)
    
    lazy var autoplayAfterAddingOption: UserPreference<AutoplayAfterAddingOption> = .init(defaultsKey: "\(Self.keyPrefix).autoplay.afterAddingTracks.option",
                                                                                          defaultValue: Defaults.autoplayAfterAddingOption)
    
    lazy var autoplayAfterOpeningTracks: UserPreference<Bool> = .init(defaultsKey: "\(Self.keyPrefix).autoplay.afterOpeningTracks",
                                                                      defaultValue: Defaults.autoplayAfterOpeningTracks)
    
    lazy var autoplayAfterOpeningOption: UserPreference<AutoplayAfterOpeningOption> = .init(defaultsKey: "\(Self.keyPrefix).autoplay.afterOpeningTracks.option",
                                                                                            defaultValue: Defaults.autoplayAfterOpeningOption)
    
    lazy var rememberLastPositionForAllTracks: UserPreference<Bool> = .init(defaultsKey: "\(Self.keyPrefix).rememberLastPositionForAllTracks",
                                                                                                defaultValue: Defaults.rememberLastPositionForAllTracks)

    enum SeekLengthOption: String, CaseIterable {
        
        case constant
        case percentage
    }
    
    enum AutoplayOnStartupOption: String, CaseIterable {
        
        case firstTrack
        case resumeSequence
    }

    // Possible options for the "autoplay afer adding tracks" user preference
    enum AutoplayAfterAddingOption: String, CaseIterable {
        
        case ifNotPlaying
        case always
    }

    // Possible options for the "autoplay afer 'Open With'" user preference
    enum AutoplayAfterOpeningOption: String, CaseIterable {

        case ifNotPlaying
        case always
    }

    enum RememberSettingsForTrackOption: String, CaseIterable {
        
        case allTracks
        case individualTracks
    }
}
