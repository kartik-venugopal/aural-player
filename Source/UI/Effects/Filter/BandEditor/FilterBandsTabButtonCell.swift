//
//  FilterBandsTabButtonCell.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class FilterBandsTabButtonCell: TabGroupButtonCell {
    
    override var yOffset: CGFloat {0}
    override var textFont: NSFont {systemFontScheme.smallFont}
    override var boldTextFont: NSFont {systemFontScheme.smallFont}
    
    override var borderRadius: CGFloat {1}
    
//    override var selectionBoxColor: NSColor {Colors.selectedTabButtonColor}
    
//    override var unselectedTextColor: NSColor {Colors.tabButtonTextColor}
//    override var selectedTextColor: NSColor {Colors.selectedTabButtonTextColor}
    
    private static let underlineHeight: CGFloat = 1
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let font = isOn ? boldTextFont : textFont
        
        // Selection underline
        if isOn {
            
            let underlineWidth = title.size(withFont: font).width
            let selRect = NSRect(x: cellFrame.centerX - (underlineWidth / 2), y: cellFrame.minY + 2,
                                 width: underlineWidth, height: Self.underlineHeight)
            
            selRect.fill(withColor: selectionBoxColor)
        }
        
        // Title
        let textColor = shouldHighlight ? highlightColor : (isOff ? unselectedTextColor : selectedTextColor)
        title.drawCentered(in: cellFrame, withFont: font, andColor: textColor, yOffset: yOffset - (isOn ? -1 : 0))
    }
}
