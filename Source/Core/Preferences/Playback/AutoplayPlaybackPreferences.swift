//
// AutoplayPlaybackPreferences.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

class AutoplayPlaybackPreferences {
    
    @UserPreference(key: "playback.autoplay.onStartup", defaultValue: Defaults.autoplayOnStartup)
    var autoplayOnStartup: Bool
    
    @EnumUserPreference(key: "playback.autoplay.onStartup.option", defaultValue: Defaults.autoplayOnStartupOption)
    var autoplayOnStartupOption: AutoplayOnStartupOption
    
    @UserPreference(key: "playback.autoplay.afterAddingTracks", defaultValue: Defaults.autoplayAfterAddingTracks)
    var autoplayAfterAddingTracks: Bool
    
    @EnumUserPreference(key: "playback.autoplay.afterAddingTracks.option", defaultValue: Defaults.autoplayAfterAddingOption)
    var autoplayAfterAddingOption: AutoplayAfterAddingOption
    
    @UserPreference(key: "playback.autoplay.afterOpeningTracks", defaultValue: Defaults.autoplayAfterOpeningTracks)
    var autoplayAfterOpeningTracks: Bool
    
    @EnumUserPreference(key: "playback.autoplay.afterOpeningTracks.option", defaultValue: Defaults.autoplayAfterOpeningOption)
    var autoplayAfterOpeningOption: AutoplayAfterOpeningOption
    
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
    
    fileprivate struct Defaults {
        
        static let autoplayOnStartup: Bool = false
        static let autoplayOnStartupOption: AutoplayOnStartupOption = .firstTrack
        
        static let autoplayAfterAddingTracks: Bool = false
        static let autoplayAfterAddingOption: AutoplayAfterAddingOption = .ifNotPlaying
        
        static let autoplayAfterOpeningTracks: Bool = true
        static let autoplayAfterOpeningOption: AutoplayAfterOpeningOption = .always
    }
}
