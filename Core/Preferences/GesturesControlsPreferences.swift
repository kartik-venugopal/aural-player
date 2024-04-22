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
    
    var allowVolumeControl: Bool = true
    var allowSeeking: Bool = true
    var allowTrackChange: Bool = true
    
    var allowPlaylistNavigation: Bool = true
    var allowPlaylistTabToggle: Bool = true
    
    var volumeControlSensitivity: ScrollSensitivity = .high
    var seekSensitivity: ScrollSensitivity = .low
    
    private static let keyPrefix: String = "controls.gestures"
    
    static let key_allowVolumeControl: String = "\(keyPrefix).allowVolumeControl"
    static let key_allowSeeking: String = "\(keyPrefix).allowSeeking"
    static let key_allowTrackChange: String = "\(keyPrefix).allowTrackChange"
    
    static let key_allowPlaylistNavigation: String = "\(keyPrefix).allowPlaylistNavigation"
    static let key_allowPlaylistTabToggle: String = "\(keyPrefix).allowPlaylistTabToggle"
    
    static let key_volumeControlSensitivity: String = "\(keyPrefix).volumeControlSensitivity"
    static let key_seekSensitivity: String = "\(keyPrefix).seekSensitivity"
    
    private typealias Defaults = PreferencesDefaults.Controls.Gestures
    
    init() {
        
//        allowVolumeControl = dict[Self.key_allowVolumeControl, Bool.self] ?? Defaults.allowVolumeControl
//        
//        allowSeeking = dict[Self.key_allowSeeking, Bool.self] ?? Defaults.allowSeeking
//        
//        allowTrackChange = dict[Self.key_allowTrackChange, Bool.self] ?? Defaults.allowTrackChange
//        
//        allowPlaylistNavigation = dict[Self.key_allowPlaylistNavigation, Bool.self] ?? Defaults.allowPlaylistNavigation
//        
//        allowPlaylistTabToggle = dict[Self.key_allowPlaylistTabToggle, Bool.self] ?? Defaults.allowPlaylistTabToggle
//        
//        volumeControlSensitivity = dict.enumValue(forKey: Self.key_volumeControlSensitivity, ofType: ScrollSensitivity.self) ??  Defaults.volumeControlSensitivity
//        
//        seekSensitivity = dict.enumValue(forKey: Self.key_seekSensitivity, ofType: ScrollSensitivity.self) ?? Defaults.seekSensitivity
    }
}

enum ScrollSensitivity: String, CaseIterable {
    
    case low
    case medium
    case high
}
