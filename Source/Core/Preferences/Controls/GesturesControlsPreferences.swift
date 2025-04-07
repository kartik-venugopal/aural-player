//
//  GesturesControlsPreferences.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all user preferences pertaining to the use of trackpad / mouse gestures with this application.
///
class GesturesControlsPreferences {
    
    @UserPreference(key: "controls.gestures.allowVolumeControl", defaultValue: Defaults.allowVolumeControl)
    var allowVolumeControl: Bool
    
    @EnumUserPreference(key: "controls.gestures.volumeControlSensitivity", defaultValue: Defaults.volumeControlSensitivity)
    var volumeControlSensitivity: ScrollSensitivity
    
    @UserPreference(key: "controls.gestures.allowSeeking", defaultValue: Defaults.allowSeeking)
    var allowSeeking: Bool
    
    @EnumUserPreference(key: "controls.gestures.seekSensitivity", defaultValue: Defaults.seekSensitivity)
    var seekSensitivity: ScrollSensitivity
    
    @UserPreference(key: "controls.gestures.allowTrackChange", defaultValue: Defaults.allowTrackChange)
    var allowTrackChange: Bool
    
    @UserPreference(key: "controls.gestures.allowPlayQueueScrolling.topToBottom", defaultValue: Defaults.allowPlayQueueScrollingTopToBottom)
    var allowPlayQueueScrollingTopToBottom: Bool
    
    @UserPreference(key: "controls.gestures.allowPlayQueueScrolling.pageUpDown", defaultValue: Defaults.allowPlayQueueScrollingPageUpDown)
    var allowPlayQueueScrollingPageUpDown: Bool
    
    init(legacyPreferences: LegacyGesturesControlsPreferences? = nil) {
        
        guard let legacyPreferences = legacyPreferences else {return}
        
        if let allowPlaylistNavigation = legacyPreferences.allowPlaylistNavigation {
            self.allowPlayQueueScrollingTopToBottom = allowPlaylistNavigation
        }
        
        legacyPreferences.deleteAll()
    }
    
    enum ScrollSensitivity: String, CaseIterable {
        
        case low
        case medium
        case high
    }
    
    ///
    /// An enumeration of default values for trackpad / mouse gestures preferences.
    ///
    fileprivate struct Defaults {
        
        static let allowVolumeControl: Bool = true
        static let allowSeeking: Bool = true
        static let allowTrackChange: Bool = true
        
        static let allowPlayQueueScrollingTopToBottom: Bool = true
        static let allowPlayQueueScrollingPageUpDown: Bool = true
        
        static let volumeControlSensitivity: ScrollSensitivity = .medium
        static let seekSensitivity: ScrollSensitivity = .medium
        
    }
}
