//
//  Fonts.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
    
    static let menuFont: NSFont = FontConstants.Standard.mainFont_11
    
    static let stringInputPopoverFont: NSFont = FontConstants.Standard.mainFont_12_5
    static let stringInputPopoverErrorFont: NSFont = FontConstants.Standard.mainFont_11_5
    
    static let largeTabButtonFont: NSFont = FontConstants.Standard.captionFont_14
    
    static let helpInfoTextFont: NSFont = FontConstants.Standard.mainFont_12
    
    static let presetsManagerTableHeaderTextFont: NSFont = FontConstants.Standard.mainFont_13
    static let presetsManagerTableTextFont: NSFont = FontConstants.Standard.mainFont_12
    static let presetsManagerTableSelectedTextFont: NSFont = FontConstants.Standard.mainFont_12
    
    // Font used by the playlist tab view buttons
    static let tabViewButtonFont: NSFont = FontConstants.Standard.mainFont_12
    static let tabViewButtonBoldFont: NSFont = FontConstants.Standard.mainFont_12
    
    // Font used by modal dialog buttons
    static let modalDialogButtonFont: NSFont = FontConstants.Standard.mainFont_12
    
    // Font used by modal dialog control buttons
    static let modalDialogControlButtonFont: NSFont = FontConstants.Standard.mainFont_11
    
    // Font used by the search modal dialog navigation buttons
    static let modalDialogNavButtonFont: NSFont = FontConstants.Standard.mainFont_12
    
    // Font used by modal dialog check and radio buttons
    static let checkRadioButtonFont: NSFont = FontConstants.Standard.mainFont_11
    
    // Font used by the popup menus
    static let popupMenuFont: NSFont = FontConstants.Standard.mainFont_10
    
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
