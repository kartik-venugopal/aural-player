//
//  LastFMPreferences.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

class LastFMPreferences {
    
    private static let keyPrefix: String = "metadata.lastFM"
    private typealias Defaults = PreferencesDefaults.Metadata.LastFM
    
    lazy var sessionKey: OptionalMuthu<String> = .init(defaultsKey: "\(Self.keyPrefix).sessionKey")
    
    var hasSessionKey: Bool {
        sessionKey.value != nil
    }
    
    lazy var enableScrobbling: UserMuthu<Bool> = .init(defaultsKey: "\(Self.keyPrefix).enableScrobbling", defaultValue: Defaults.enableScrobbling)
    
    lazy var enableLoveUnlove: UserMuthu<Bool> = .init(defaultsKey: "\(Self.keyPrefix).enableLoveUnlove", defaultValue: Defaults.enableLoveUnlove)
}
