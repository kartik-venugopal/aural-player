//
//  BookmarksNotifications.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Notifications pertaining to the *Bookmarks* list.
///
extension Notification.Name {
    
    struct Bookmarks {
        
        // Signifies that a bookmark has been added to the bookmarks list.
        static let added = Notification.Name("bookmarks_added")
        
        // Signifies that bookmarks have been removed from the bookmarks list.
        static let removed = Notification.Name("bookmarks_removed")
    }
}
