//
//  FavoritesListNotifications.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Notifications pertaining to the *Favorites* list.
///
extension Notification.Name {
    
    // Signifies that a track has been added to the favorites list.
    static let favoritesList_trackAdded = Notification.Name("favoritesList_trackAdded")
    
    // Signifies that tracks have been removed from the favorites list.
    static let favoritesList_tracksRemoved = Notification.Name("favoritesList_tracksRemoved")
    
    // Commands the Favorites list to add/remove the currently playing track to/from the list.
    // Functions as a toggle: add/remove.
    static let favoritesList_addOrRemove = Notification.Name("favoritesList_addOrRemove")
}
