//
//  ChaptersListTableHeaderCell.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class ChaptersListTableHeaderCell: NSTableHeaderCell {
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        cellFrame.fill(withColor: systemColorScheme.backgroundColor)
        
        let size: CGSize = stringValue.size(withFont: systemFontScheme.normalFont)
        
        // Calculate the x co-ordinate for text rendering, according to its intended aligment
        var x: CGFloat = 0
        
        switch stringValue {
            
        case "#":
            
            // Left alignment
            x = cellFrame.minX + 7
            
        case "Title":
            
            // Left alignment
            x = cellFrame.minX
            
        case "Start Time", "Duration":
            
            // Right alignment
            x = cellFrame.maxX - size.width - 5
            
        default:
            
            return
        }
    
        let rect = NSRect(x: x, y: cellFrame.minY, width: size.width, height: cellFrame.height)
        stringValue.draw(in: rect, withFont: systemFontScheme.normalFont,
                         andColor: systemColorScheme.secondaryTextColor)
    }
}
