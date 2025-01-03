//
//  GesturesControlsPreferences.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all user preferences pertaining to the use of trackpad / mouse gestures with this application.
///
class GesturesControlsPreferences {
    
    lazy var allowVolumeControl: UserPreference<Bool> = .init(defaultsKey: "\(Self.keyPrefix).allowVolumeControl",
                                                              defaultValue: Defaults.allowVolumeControl)
    
    lazy var volumeControlSensitivity: UserPreference<ScrollSensitivity> = .init(defaultsKey: "\(Self.keyPrefix).volumeControlSensitivity",
                                                                                 defaultValue: Defaults.volumeControlSensitivity)
    
    lazy var allowSeeking: UserPreference<Bool> = .init(defaultsKey: "\(Self.keyPrefix).allowSeeking",
                                                        defaultValue: Defaults.allowSeeking)
    
    lazy var seekSensitivity: UserPreference<ScrollSensitivity> = .init(defaultsKey: "\(Self.keyPrefix).seekSensitivity",
                                                                        defaultValue: Defaults.seekSensitivity)
    
    lazy var allowTrackChange: UserPreference<Bool> = .init(defaultsKey: "\(Self.keyPrefix).allowTrackChange",
                                                            defaultValue: Defaults.allowTrackChange)
    
    lazy var allowPlayQueueScrollingTopToBottom: UserPreference<Bool> = .init(defaultsKey: "\(Self.keyPrefix).allowPlayQueueScrolling.topToBottom",
                                                                              defaultValue: Defaults.allowPlayQueueScrollingTopToBottom)
    
    lazy var allowPlayQueueScrollingPageUpDown: UserPreference<Bool> = .init(defaultsKey: "\(Self.keyPrefix).allowPlayQueueScrolling.pageUpDown",
                                                                             defaultValue: Defaults.allowPlayQueueScrollingPageUpDown)
    
    private static let keyPrefix: String = "controls.gestures"
    private typealias Defaults = PreferencesDefaults.Controls.Gestures
    
    init(legacyPreferences: LegacyGesturesControlsPreferences? = nil) {
        
        guard let legacyPreferences = legacyPreferences else {return}
        
        if let allowPlaylistNavigation = legacyPreferences.allowPlaylistNavigation {
            self.allowPlayQueueScrollingTopToBottom.value = allowPlaylistNavigation
        }
        
        legacyPreferences.deleteAll()
    }
    
    enum ScrollSensitivity: String, CaseIterable {
        
        case low
        case medium
        case high
    }
}
