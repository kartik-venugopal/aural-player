//
//  RemoteControlPreferences.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
    
    var enabled: Bool = true
    var trackChangeOrSeekingOption: TrackChangeOrSeekingOptions = .trackChange
    
    private static let keyPrefix: String = "controls.remoteControl"
    
    static let key_enabled: String = "\(keyPrefix).enabled"
    static let key_trackChangeOrSeekingOption: String = "\(keyPrefix).trackChangeOrSeekingOption"
    
    private typealias Defaults = PreferencesDefaults.Controls.RemoteControl
    
    init() {
    }
}

enum TrackChangeOrSeekingOptions: String, CaseIterable {
    
    case trackChange
    case seeking
}
