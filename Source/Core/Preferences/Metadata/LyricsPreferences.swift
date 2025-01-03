//
// LyricsPreferences.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

class LyricsPreferences {
    
    private static let keyPrefix: String = "metadata.lyrics"
    private typealias Defaults = PreferencesDefaults.Metadata.Lyrics
    
    lazy var showWindowWhenPresent: UserPreference<Bool> = .init(defaultsKey: "\(Self.keyPrefix).showWindowWhenPresent",
                                                                 defaultValue: Defaults.showWindowWhenPresent)
    
    lazy var enableAutoSearch: UserPreference<Bool> = .init(defaultsKey: "\(Self.keyPrefix).enableAutoSearch",
                                                                 defaultValue: Defaults.enableAutoSearch)
}
