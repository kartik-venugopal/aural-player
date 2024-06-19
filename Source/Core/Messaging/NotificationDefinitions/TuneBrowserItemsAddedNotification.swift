//
//  TuneBrowserItemsAddedNotification.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct TuneBrowserItemsAddedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .fileSystem_childrenAddedToItem
    
    let parentItem: FileSystemItem
    let childIndices: IndexSet
}
