//
//  TrackListViewsButtonCell.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class TrackListViewsButtonCell: TabGroupButtonCell {
    
    var button: TrackListTabButton {
        controlView as! TrackListTabButton
    }
    
    @IBInspectable var imgWidth: Int = 13
    @IBInspectable var imgHeight: Int = 13
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        drawInterior(withFrame: cellFrame, in: controlView)
    }
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let imgWidth = CGFloat(self.imgWidth)
        let halfImgWidth = imgWidth / 2
        
        let imgHeight = CGFloat(self.imgHeight)
        
        // Draw image (left aligned)
        let rectWidth: CGFloat = cellFrame.width, rectHeight: CGFloat = cellFrame.height
        let xInset = (rectWidth - imgWidth) / 2
        let yInset = (rectHeight - imgHeight) / 2
        
        // Raise the selected tab image by a few pixels so it is prominent
        let imgRect = cellFrame.insetBy(dx: xInset, dy: yInset).offsetBy(dx: 0, dy: button.isSelected ? -1 : 0)
        self.image?.filledWithColor(button.isSelected ? systemColorScheme.buttonColor : systemColorScheme.inactiveControlColor).draw(in: imgRect)
        
        // Selection underline
        if button.isSelected {
            
            let drawRect = NSRect(x: cellFrame.centerX - halfImgWidth, y: cellFrame.maxY - 2,
                                  width: imgWidth, height: 1)
            
            drawRect.fill(withColor: systemColorScheme.buttonColor)
        }
    }
}
