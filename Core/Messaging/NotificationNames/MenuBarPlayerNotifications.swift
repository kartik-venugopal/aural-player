//
//  MenuBarPlayerNotifications.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

///
/// Notifications published by / to the menu bar player.
///
extension Notification.Name {
    
    struct MenuBarPlayer {
        
        static let showSettings = Notification.Name("menuBarPlayer_showSettings")
        static let togglePlayQueue = Notification.Name("menuBarPlayer_togglePlayQueue")
        static let showSearch = Notification.Name("menuBarPlayer_showSearch")
    }
}
