//
//  PlaylistViewsButtonCell.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlaylistViewsButtonCell: TabGroupButtonCell {
    
    override var unselectedTextColor: NSColor {Colors.tabButtonTextColor}
    override var selectedTextColor: NSColor {Colors.selectedTabButtonTextColor}
    
    override var borderRadius: CGFloat {3}
    override var selectionBoxColor: NSColor {Colors.selectedTabButtonColor}
    
    override var textFont: NSFont {Fonts.Playlist.tabButtonTextFont}
    override var boldTextFont: NSFont {Fonts.Playlist.tabButtonTextFont}
    
    override var borderInsetY: CGFloat {0}
    
    override var yOffset: CGFloat {0}
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let font = isOn ? boldTextFont : textFont
        
        // Selection underline
        if isOn {
            
            let underlineWidth = title.size(withFont: font).width
            let selRect = NSRect(x: cellFrame.centerX - (underlineWidth / 2), y: cellFrame.maxY - 2, width: underlineWidth, height: 2)
            
            selRect.fill(withColor: selectionBoxColor)
        }
        
        // Title
        let textColor = shouldHighlight ? highlightColor : (isOff ? unselectedTextColor : selectedTextColor)
        title.drawCentered(in: cellFrame, withFont: font, andColor: textColor, yOffset: yOffset - (isOn ? 2 : 0))
    }
}
