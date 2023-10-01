//
//  PlaylistCommandNotification.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// A base class for commands sent to the playlist.
///
class PlaylistCommandNotification: NotificationPayload {

    let notificationName: Notification.Name
    
    // Helps determine which playlist view(s) the command is intended for.
    let viewSelector: PlaylistViewSelector
    
    init(notificationName: Notification.Name, viewSelector: PlaylistViewSelector) {
        
        self.notificationName = notificationName
        self.viewSelector = viewSelector
    }
}
