//
// LyricsNotifications.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension Notification.Name {
    
    struct Lyrics {
        
        static let loadFromFile = Notification.Name("lyrics_loadFromFile")
        static let addLyricsFile = Notification.Name("lyrics_addLyricsFile")
        static let searchForLyricsOnline = Notification.Name("lyrics_searchForLyricsOnline")
        static let removeDownloadedLyrics = Notification.Name("lyrics_removeDownloadedLyrics")
        static let karaokeModePreferenceUpdated = Notification.Name("lyrics_karaokeModePreferenceUpdated")
    }
}
