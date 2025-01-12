//
//  OpenTuneBrowserFolderCommandNotification.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct OpenTuneBrowserFolderCommandNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .tuneBrowser_openFolder
    
    let folderToOpen: FileSystemFolderItem
    let treeContainingFolder: FileSystemTree
    let currentlyOpenFolder: FileSystemFolderItem   // For History
}
