//
//  FilterBandsTabButtonCell.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class FilterBandsTabButtonCell: TabGroupButtonCell {
    
    override var yOffset: CGFloat {0}
    override var textFont: NSFont {Fonts.Effects.unitFunctionFont}
    override var boldTextFont: NSFont {Fonts.Effects.unitFunctionFont}
    
    override var borderRadius: CGFloat {1}
    
    override var selectionBoxColor: NSColor {Colors.selectedTabButtonColor}
    
    override var unselectedTextColor: NSColor {Colors.tabButtonTextColor}
    override var selectedTextColor: NSColor {Colors.selectedTabButtonTextColor}
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let font = isOn ? boldTextFont : textFont
        
        // Selection underline
        if isOn {
            
            let underlineWidth = title.size(withFont: font).width
            let selRect = NSRect(x: cellFrame.centerX - (underlineWidth / 2), y: cellFrame.minY + 2, width: underlineWidth, height: 1)
            selectionBoxColor.setFill()
            selRect.fill()
        }
        
        // Title
        let textColor = shouldHighlight ? highlightColor : (isOff ? unselectedTextColor : selectedTextColor)
        GraphicsUtils.drawCenteredTextInRect(cellFrame, title, textColor, font, yOffset - (isOn ? -1 : 0))
    }
}
