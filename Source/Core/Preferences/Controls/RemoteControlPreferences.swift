//
//  RemoteControlPreferences.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all user preferences pertaining to the **Remote Control** feature, i.e. the ability
/// to control the app from outside it.
///
class RemoteControlPreferences {
    
    @UserPreference(key: "controls.remoteControl.enabled", defaultValue: Defaults.enabled)
    var enabled: Bool
    
    @EnumUserPreference(key: "controls.remoteControl.trackChangeOrSeekingOption", defaultValue: Defaults.trackChangeOrSeekingOption)
    var trackChangeOrSeekingOption: TrackChangeOrSeekingOptions
    
    enum TrackChangeOrSeekingOptions: String, CaseIterable {
        
        case trackChange
        case seeking
    }
    
    ///
    /// An enumeration of default values for **Remote Control** preferences.
    ///
    fileprivate struct Defaults {
        
        static let enabled: Bool = true
        static let trackChangeOrSeekingOption: TrackChangeOrSeekingOptions = .trackChange
    }
}
