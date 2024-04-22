//
//  FavoritesListNotifications.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Notifications pertaining to the *Favorites* list.
///
extension Notification.Name {
    
    struct Favorites {
        
        // Signifies that a track has been added to the favorites list.
        static let itemAdded = Notification.Name("favorites_itemAdded")
        
        // Signifies that tracks have been removed from the favorites list.
        static let itemsRemoved = Notification.Name("favorites_itemsRemoved")
        
        // Commands the Favorites list to add/remove the currently playing track to/from the list.
        // Functions as a toggle: add/remove.
        static let addOrRemove = Notification.Name("favorites_addOrRemove")
    }
}
