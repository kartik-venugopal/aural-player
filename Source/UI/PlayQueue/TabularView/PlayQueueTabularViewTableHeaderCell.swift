//
// PlayQueueTabularViewTableHeaderCell.swift
// Aural
// 
// Copyright © 2024 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

class PlayQueueTabularViewTableHeaderCell: NSTableHeaderCell {
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        cellFrame.fill(withColor: systemColorScheme.backgroundColor)
        
        if stringValue != "#" {
            
            GraphicsUtils.drawLine(systemColorScheme.tertiaryTextColor, pt1: NSMakePoint(cellFrame.minX + 1, cellFrame.minY + 2), pt2: NSMakePoint(cellFrame.minX + 1, cellFrame.maxY - 5), width: 1)
        }
        
        let size: CGSize = stringValue.size(withFont: systemFontScheme.normalFont)
        
        // Calculate the x co-ordinate for text rendering, according to its intended aligment
        
        var x: CGFloat = 0
        
        switch stringValue {
            
        case "#":
            
            // Left alignment
            x = cellFrame.minX + 7
            
        case "Duration":
            
            // Right alignment
            x = cellFrame.maxX - size.width - 5
            
        default:
            
            // Left alignment
            x = cellFrame.minX + 10
        }
        
        let rect = NSRect(x: x, y: cellFrame.minY + 5, width: size.width, height: cellFrame.height)
        stringValue.draw(in: rect, withFont: systemFontScheme.normalFont,
                         andColor: systemColorScheme.tertiaryTextColor)
    }
}
