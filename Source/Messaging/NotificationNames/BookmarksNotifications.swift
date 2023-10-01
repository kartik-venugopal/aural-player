//
//  BookmarksNotifications.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Notifications pertaining to the *Bookmarks* list.
///
extension Notification.Name {
    
    // Signifies that a track has been added to the bookmarks list.
    static let bookmarksList_trackAdded = Notification.Name("bookmarksList_trackAdded")
    
    // Signifies that tracks have been removed from the bookmarks list.
    static let bookmarksList_tracksRemoved = Notification.Name("bookmarksList_tracksRemoved")
}
