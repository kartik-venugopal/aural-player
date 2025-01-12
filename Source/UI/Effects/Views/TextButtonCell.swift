//
// TextButtonCell.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

class TextButtonCell: NSButtonCell {
    
    var rectRadius: CGFloat {4}
    
    var borderColor: NSColor {systemColorScheme.buttonColor}
    var titleFont: NSFont {systemFontScheme.normalFont}
    var titleColor: NSColor {systemColorScheme.primaryTextColor}
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        NSBezierPath.strokeRoundedRect(cellFrame.insetBy(dx: 0.5, dy: 0.5), radius: rectRadius, withColor: borderColor)
        
        title.drawCentered(in: cellFrame,
                                  withFont: titleFont, andColor: titleColor, yOffset: 1)
    }
}
