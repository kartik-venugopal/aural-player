//
//  EQSelectorButtonCell.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class EQSelectorButtonCell: TabGroupButtonCell {
    
    override var textFont: NSFont {Fonts.Effects.unitFunctionFont}
    override var boldTextFont: NSFont {Fonts.Effects.unitFunctionFont}
    
    override var borderRadius: CGFloat {return 1}
    
    override var selectionBoxColor: NSColor {return Colors.selectedTabButtonColor}
    
    override var unselectedTextColor: NSColor {return Colors.tabButtonTextColor}
    override var selectedTextColor: NSColor {return Colors.selectedTabButtonTextColor}
    
    override var yOffset: CGFloat {0}
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let font = isOn ? boldTextFont : textFont
        
        // Selection dot
        if isOn {
            
            let textWidth = title.size(withFont: font).width
            let markerSize: CGFloat = 6
            let markerX = cellFrame.centerX - (textWidth / 2) - 5 - markerSize
            let markerRect = NSRect(x: markerX, y: cellFrame.centerY - (markerSize / 2) + yOffset + 1, width: markerSize, height: markerSize)
            let roundedPath = NSBezierPath.init(roundedRect: markerRect, xRadius: borderRadius, yRadius: borderRadius)
            
            selectionBoxColor.setFill()
            roundedPath.fill()
        }
        
        // Title
        let textColor = shouldHighlight ? highlightColor : (isOff ? unselectedTextColor : selectedTextColor)
        title.drawCentered(in: cellFrame, withFont: font, andColor: textColor, offset: yOffset)
    }
}
