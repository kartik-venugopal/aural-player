//
//  ChaptersListTableHeaderCell.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class ChaptersListTableHeaderCell: NSTableHeaderCell {
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        Colors.windowBackgroundColor.setFill()
        cellFrame.fill()
        
        let attrsDict: [NSAttributedString.Key: Any] = [
            .font: Fonts.Playlist.chaptersListHeaderFont,
            .foregroundColor: Colors.Playlist.summaryInfoColor]
        
        let size: CGSize = stringValue.size(withAttributes: attrsDict)
        
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
        stringValue.draw(in: rect, withAttributes: attrsDict)
    }
}
