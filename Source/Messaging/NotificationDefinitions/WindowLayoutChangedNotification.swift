//
//  WindowLayoutChangedNotification.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Notification that the window manager has changed the window layout.
///
struct WindowLayoutChangedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .windowManager_layoutChanged

    // Whether or not the playlist window is now being shown.
    let showingPlaylistWindow: Bool
    
    // Whether or not the effects window is now being shown.
    let showingEffectsWindow: Bool
}
