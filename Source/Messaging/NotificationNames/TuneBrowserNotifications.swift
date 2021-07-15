//
//  TuneBrowserNotifications.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Notifications pertaining to the **Tune Browser**.
///
extension Notification.Name {
    
    static let fileSystem_fileMetadataLoaded = Notification.Name("fileSystem_fileMetadataLoaded")
    
    static let tuneBrowser_sidebarSelectionChanged = Notification.Name("tuneBrowser_sidebarSelectionChanged")
}
