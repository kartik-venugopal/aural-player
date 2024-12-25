//
//  ColorConstants.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

extension NSColor {
    
    static let white7Percent: NSColor = NSColor(white: 0.07)
    static let white8Percent: NSColor = NSColor(white: 0.08)
    static let white10Percent: NSColor = NSColor(white: 0.1)
    static let white15Percent: NSColor = NSColor(white: 0.15)
    static let white20Percent: NSColor = NSColor(white: 0.2)
    static let white22Percent: NSColor = NSColor(white: 0.22)
    static let white25Percent: NSColor = NSColor(white: 0.25)
    static let white30Percent: NSColor = NSColor(white: 0.3)
    static let white35Percent: NSColor = NSColor(white: 0.35)
    static let white37Percent: NSColor = NSColor(white: 0.37)
    static let white40Percent: NSColor = NSColor(white: 0.4)
    static let white45Percent: NSColor = NSColor(white: 0.45)
    static let white50Percent: NSColor = NSColor(white: 0.5)
    static let white55Percent: NSColor = NSColor(white: 0.55)
    static let white60Percent: NSColor = NSColor(white: 0.6)
    static let white65Percent: NSColor = NSColor(white: 0.65)
    static let white70Percent: NSColor = NSColor(white: 0.7)
    static let white75Percent: NSColor = NSColor(white: 0.75)
    static let white80Percent: NSColor = NSColor(white: 0.8)
    static let white85Percent: NSColor = NSColor(white: 0.85)
    static let white90Percent: NSColor = NSColor(white: 0.9)
    
    static let green75Percent: NSColor = NSColor(red: 0, green: 0.75, blue: 0)
    static let green50Percent: NSColor = NSColor(red: 0, green: 0.5, blue: 0)
    
    static let aqua: NSColor = NSColor(red: 0, green: 0.5, blue: 1)
    
    static let lava: NSColor = NSColor(red: 0.73, green: 0.294, blue: 0.153)
    
    static let presetsManagerTableHeaderTextColor: NSColor = .white85Percent
    
    // Color of text inside the playlist (non-selected items)
    static let defaultLightTextColor: NSColor = .white60Percent
    
    // Color of selected item text inside the playlist
    static let defaultSelectedLightTextColor: NSColor = .white
    
    // Fill color of box drawn around selected playlist item
    static let playlistSelectionBoxColor: NSColor = .white15Percent
    
    // Color used for text in tab view buttons
    static let tabViewButtonTextColor: NSColor = .white90Percent
    
    // Color of the arrow drawn on popup menus
    static let popupMenuArrowColor: NSColor = .white10Percent
    
    static let popupMenuColor: NSColor = .white50Percent
    
    // A lighter version of popupMenuArrowColor
    static let lightPopupMenuArrowColor: NSColor = .white80Percent
    
    // Color of the ticks/notches on sliders
    static let sliderNotchColor: NSColor = NSColor.black
    
    // Fill color of box drawn around selected tab view item
    static let tabViewSelectionBoxColor: NSColor = NSColor(white: 0.125)
    
    // Text color of modal dialog buttons
    static let modalDialogButtonTextColor: NSColor = .white90Percent
    
    // Text color of modal dialog buttons
    static let modalDialogButtonTextColor_disabled: NSColor = .white50Percent
    
    // Fill color of text in modal dialog navigation buttons (search)
    static let modalDialogNavButtonTextColor: NSColor = .white90Percent
    
    // Color of cursor inside text fields
    static let textFieldCursorColor: NSColor = .white50Percent
    
    // Background color of the popover view
    static let popoverBackgroundColor: NSColor = .white15Percent
    
    // Color of text inside any of the container boxes
    static let boxTextColor: NSColor = .white70Percent
}
