//
//  HistoryNotifications.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
    
    // Signifies that new items have been added to the playlist (ie. new items to be added to the recently added history list).
    static let history_itemsAdded = Notification.Name("history_itemsAdded")
    
    // Signifies that the history lists have been updated.
    static let history_updated = Notification.Name("history_updated")
}
