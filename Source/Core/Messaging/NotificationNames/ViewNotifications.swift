//
//  ViewNotifications.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

extension Notification.Name {
    
    struct View {
        
        static let toggleEffects = Notification.Name("view_toggleEffects")
        static let togglePlayQueue = Notification.Name("view_togglePlayQueue")
        static let toggleChaptersList = Notification.Name("view_toggleChaptersList")
        static let toggleVisualizer = Notification.Name("view_toggleVisualizer")
        static let toggleTrackInfo = Notification.Name("view_toggleTrackInfo")
        static let toggleWaveform = Notification.Name("view_toggleWaveform")
        static let toggleLyrics = Notification.Name("view_toggleLyrics")

        static let changeWindowCornerRadius = Notification.Name("view_changeWindowCornerRadius")
        
        struct CompactPlayer {
            
            static let showPlayer = Notification.Name("view_compactPlayer_showPlayer")
        }
    }
}
