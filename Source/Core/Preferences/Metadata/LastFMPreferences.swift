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
    
    @OptionalUserPreference(key: "metadata.lastFM.sessionKey")
    var sessionKey: String?
    
    var hasSessionKey: Bool {
        sessionKey != nil
    }
    
    @UserPreference(key: "metadata.lastFM.enableScrobbling", defaultValue: Defaults.enableScrobbling)
    var enableScrobbling: Bool
    
    @UserPreference(key: "metadata.lastFM.enableLoveUnlove", defaultValue: Defaults.enableLoveUnlove)
    var enableLoveUnlove: Bool
    
    ///
    /// An enumeration of default values for **LastFM** metadata scrobbling / retrieval preferences.
    ///
    fileprivate struct Defaults {
        
        static let enableScrobbling: Bool = false
        static let enableLoveUnlove: Bool = false
    }
}
