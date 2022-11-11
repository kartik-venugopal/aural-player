//
//  Fonts.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
 Container for fonts used by the UI
 */
struct Fonts {
    
    private static let fontSchemesManager: FontSchemesManager = objectGraph.fontSchemesManager
    
    struct Player {
        
        static var infoBoxTitleFont: NSFont {fontSchemesManager.systemScheme.player.infoBoxTitleFont}
        static var infoBoxArtistAlbumFont: NSFont {fontSchemesManager.systemScheme.player.infoBoxArtistAlbumFont}
        static var infoBoxChapterTitleFont: NSFont {fontSchemesManager.systemScheme.player.infoBoxChapterTitleFont}
    }
    
    struct Playlist {
        
        static var trackTextFont: NSFont {fontSchemesManager.systemScheme.playlist.trackTextFont}
        
        static var groupTextFont: NSFont {fontSchemesManager.systemScheme.playlist.groupTextFont}
        
        static var tabButtonTextFont: NSFont {fontSchemesManager.systemScheme.playlist.tabButtonTextFont}
        
        static var chaptersListHeaderFont: NSFont {fontSchemesManager.systemScheme.playlist.chaptersListHeaderFont}
    }
    
    struct Effects {
        
        static var unitFunctionFont: NSFont {fontSchemesManager.systemScheme.effects.unitFunctionFont}
    }
}
