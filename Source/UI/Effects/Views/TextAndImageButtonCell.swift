//
// TextAndImageButtonCell.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

@IBDesignable
class TextAndImageButtonCell: NSButtonCell {
    
    var rectRadius: CGFloat {4}
    
    @IBInspectable var imgWidth: Int = 14
    @IBInspectable var imgHeight: Int = 14
    
    var borderColor: NSColor {systemColorScheme.buttonColor}
    var titleFont: NSFont {systemFontScheme.normalFont}
    var titleColor: NSColor {systemColorScheme.primaryTextColor}
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        NSBezierPath.strokeRoundedRect(cellFrame.insetBy(dx: 0.5, dy: 0.5), radius: rectRadius, withColor: borderColor)
        
        title.drawCentered(in: cellFrame,
                                  withFont: titleFont, andColor: titleColor, yOffset: 1)
        
        let imgWidth = CGFloat(self.imgWidth)
        let imgHeight = CGFloat(self.imgHeight)
        
        let imgX = cellFrame.maxX - imgWidth - 5
        let imgY = cellFrame.maxY - imgHeight - ((cellFrame.height - imgHeight) / 2)
        
        let imgRect = NSMakeRect(imgX, imgY, imgWidth, imgHeight)
        
        if let image = self.image?.tintedWithColor(titleColor) {
            image.draw(in: imgRect)
        }
    }
}
