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
    
    lazy var showWindowWhenPresent: UserMuthu<Bool> = .init(defaultsKey: "\(Self.keyPrefix).showWindowWhenPresent",
                                                                 defaultValue: Defaults.showWindowWhenPresent)
    
    // For timed (LRC) lyrics only
    lazy var enableAutoScroll: UserMuthu<Bool> = .init(defaultsKey: "\(Self.keyPrefix).enableAutoScroll",
                                                            defaultValue: Defaults.enableAutoScroll)
    
    // For timed (LRC) lyrics only
    lazy var enableKaraokeMode: UserMuthu<Bool> = .init(defaultsKey: "\(Self.keyPrefix).enableKaraokeMode",
                                                             defaultValue: Defaults.enableKaraokeMode)
    
    lazy var lyricsFilesDirectory: OptionalMuthu<URL> = .init(defaultsKey: "\(Self.keyPrefix).lyricsFilesDirectory")
    
    lazy var enableOnlineSearch: UserMuthu<Bool> = .init(defaultsKey: "\(Self.keyPrefix).enableOnlineSearch",
                                                            defaultValue: Defaults.enableOnlineSearch)
    
    // For timed (LRC) lyrics only
//    lazy var showTranslations: UserPreference<Bool> = .init(defaultsKey: "\(Self.keyPrefix).showTranslations",
//                                                            defaultValue: Defaults.showTranslations)
    
    fileprivate struct Defaults {
        
        static let showWindowWhenPresent: Bool = true
        static let enableAutoScroll: Bool = true
        static let enableKaraokeMode: Bool = true
        
        static let enableOnlineSearch: Bool = true
        static let showTranslations: Bool = true
    }
}
