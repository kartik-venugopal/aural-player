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
        static let showSearch = Notification.Name("compactPlayer_showSearch")
        static let showChaptersList = Notification.Name("compactPlayer_showChaptersList")
        static let showTrackInfo = Notification.Name("compactPlayer_showTrackInfo")
        
        static let toggleTrackInfoScrolling = Notification.Name("compactPlayer_toggleTrackInfoScrolling")
        
        static let toggleShowSeekPosition = Notification.Name("compactPlayer_toggleShowSeekPosition")
        
        static let changePlaybackPositionDisplayType = Notification.Name("compactPlayer_changePlaybackPositionDisplayType")
    }
}
