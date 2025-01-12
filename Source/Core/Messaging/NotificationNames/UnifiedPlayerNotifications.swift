//
//  UnifiedPlayerNotifications.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

extension Notification.Name {
    
    // MARK: Notifications published by / to the unified player.
    
    struct UnifiedPlayer {
        
        // Command to show a specific Library browser tab (specified in the payload).
        static let showModule = Notification.Name("unifiedPlayer_showModule")
        static let hideModule = Notification.Name("unifiedPlayer_hideModule")
        static let toggleModule = Notification.Name("unifiedPlayer_toggleModule")
    }
    
    // Command to show a specific Library browser tab (specified in the payload).
//    static let unifiedPlayerSidebar_addFileSystemShortcut = Notification.Name("unifiedPlayerSidebar_addFileSystemShortcut")
}
