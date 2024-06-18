//
//  CompactPlayerNotifications.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
        
        static let showSearch = Notification.Name("compactPlayer_showSearch")
        static let toggleTrackInfoScrolling = Notification.Name("compactPlayer_toggleTrackInfoScrolling")
    }
}
