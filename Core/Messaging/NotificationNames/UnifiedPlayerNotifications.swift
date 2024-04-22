//
//  UnifiedPlayerNotifications.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

extension Notification.Name {
    
    // MARK: Notifications published by / to the unified player.
    
    // Command to show a specific Library browser tab (specified in the payload).
    static let unifiedPlayer_showBrowserTabForItem = Notification.Name("unifiedPlayer_showBrowserTabForItem")
    
    // Command to show a specific Library browser tab (specified in the payload).
    static let unifiedPlayer_showBrowserTabForCategory = Notification.Name("unifiedPlayer_showBrowserTabForCategory")
    
    // Command to show a specific Library browser tab (specified in the payload).
//    static let unifiedPlayerSidebar_addFileSystemShortcut = Notification.Name("unifiedPlayerSidebar_addFileSystemShortcut")
}
