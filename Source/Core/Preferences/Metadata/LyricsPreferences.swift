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
    
    @UserPreference(key: "metadata.lyrics.showWindowWhenPresent", defaultValue: Defaults.showWindowWhenPresent)
    var showWindowWhenPresent: Bool
    
    // For timed (LRC) lyrics only
    @UserPreference(key: "metadata.lyrics.enableAutoScroll", defaultValue: Defaults.enableAutoScroll)
    var enableAutoScroll: Bool
    
    // For timed (LRC) lyrics only
    @UserPreference(key: "metadata.lyrics.enableKaraokeMode", defaultValue: Defaults.enableKaraokeMode)
    var enableKaraokeMode: Bool
    
    @URLUserPreference(key: "metadata.lyrics.lyricsFilesDirectory")
    var lyricsFilesDirectory: URL?
    
    @UserPreference(key: "metadata.lyrics.enableOnlineSearch", defaultValue: Defaults.enableOnlineSearch)
    var enableOnlineSearch: Bool
    
    fileprivate struct Defaults {
        
        static let showWindowWhenPresent: Bool = true
        static let enableAutoScroll: Bool = true
        static let enableKaraokeMode: Bool = true
        
        static let enableOnlineSearch: Bool = true
        static let showTranslations: Bool = true
    }
}
