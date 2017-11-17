//
//  Strings.swift
//  Aural
//
//  Created by Kay Ven on 11/16/17.
//  Copyright © 2017 Anonymous. All rights reserved.
//

import Foundation

struct Strings {
    
    // Default value for the label that shows a track's seek position
    static let zeroDurationString: String = "0:00"
    
    // Captions for buttons/menu items that let the user add/remove items to/from the Favorites list (Now Playing box, Playback menu, and Dock menu)
    
    static let favoritesAddCaption: String = "Add playing track to Favorites"
    static let favoritesRemoveCaption: String = "Remove playing track from Favorites"
    
    // Captions for menu items in the playlist's context menu
    
    static let favoritesAddCaption_contextMenu: String = " Add this track to Favorites"
    static let favoritesRemoveCaption_contextMenu: String = " Remove this track from Favorites"
    
    static let playThisTrackCaption: String = " Play this track"
    static let playThisGroupCaption: String = " Play this group"
    
    static let removeThisTrackCaption: String = "  Remove this track"
    static let removeThisGroupCaption: String = "  Remove this group"
    
    static let moveThisTrackUpCaption: String = "  Move this track up"
    static let moveThisGroupUpCaption: String = "  Move this group up"
    
    static let moveThisTrackDownCaption: String = "  Move this track down"
    static let moveThisGroupDownCaption: String = "  Move this group down"
}
