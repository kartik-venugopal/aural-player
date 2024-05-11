//
//  CompactPlayerNotifications.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

///
/// Notifications published by / to the compact player.
///
extension Notification.Name {
    
    struct CompactPlayer {
        
        static let showPlayer = Notification.Name("compactPlayer_showPlayer")
        static let showPlayQueue = Notification.Name("compactPlayer_showPlayQueue")
        static let toggleEffects = Notification.Name("compactPlayer_toggleEffects")
        static let showSearch = Notification.Name("compactPlayer_showSearch")
        static let showChaptersList = Notification.Name("compactPlayer_showChaptersList")
        static let showTrackInfo = Notification.Name("compactPlayer_showTrackInfo")
        
        static let toggleTrackInfoScrolling = Notification.Name("compactPlayer_toggleTrackInfoScrolling")
        
        static let toggleShowSeekPosition = Notification.Name("compactPlayer_toggleShowSeekPosition")
        
        static let changeTrackTimeDisplayType = Notification.Name("compactPlayer_changeTrackTimeDisplayType")
        
        static let changeWindowCornerRadius = Notification.Name("compactPlayer_changeWindowCornerRadius")
        
        static let switchToModularMode = Notification.Name("compactPlayer_switchToModularMode")
        static let switchToUnifiedMode = Notification.Name("compactPlayer_switchToUnifiedMode")
        static let switchToMenuBarMode = Notification.Name("compactPlayer_switchToMenuBarMode")
        static let switchToWidgetMode = Notification.Name("compactPlayer_switchToWidgetMode")
    }
}
