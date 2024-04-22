//
//  FileSystemFolderChangedNotification.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct FileSystemFolderChangedNotification: NotificationPayload {

    let notificationName: Notification.Name
    let affectedURL: URL
}

struct FileSystemItemUpdatedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .tuneBrowser_folderChanged
    let item: FileSystemItem
}
