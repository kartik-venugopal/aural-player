//
//  HistoryNotifications.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Notifications pertaining to *History* (chronological record of tracks added / played by the app).
///
extension Notification.Name {
    
    // MARK: Notifications related to the History lists (recently added / recently played).
    
    struct History {
        
        // Signifies that new items have been added to the playlist (ie. new items to be added to the recently added history list).
//        static let itemsAdded = Notification.Name("history_itemsAdded")
        
        // Signifies that the history lists have been updated.
        static let updated = Notification.Name("history_updated")
    }
}

//struct HistoryItemsAddedNotification: NotificationPayload {
//    
//    let notificationName: Notification.Name = .History.itemsAdded
//    let itemURLs: [URL]
//}
