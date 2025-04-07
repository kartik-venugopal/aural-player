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
    
    lazy var enabled: UserMuthu<Bool> = .init(defaultsKey: "\(Self.keyPrefix).enabled",
                                                                    defaultValue: Defaults.enabled)
    
    lazy var trackChangeOrSeekingOption: UserMuthu<TrackChangeOrSeekingOptions> = .init(defaultsKey: "\(Self.keyPrefix).trackChangeOrSeekingOption",
                                                                    defaultValue: Defaults.trackChangeOrSeekingOption)
    
    private static let keyPrefix: String = "controls.remoteControl"
    private typealias Defaults = PreferencesDefaults.Controls.RemoteControl
    
    enum TrackChangeOrSeekingOptions: String, CaseIterable {
        
        case trackChange
        case seeking
    }
}
