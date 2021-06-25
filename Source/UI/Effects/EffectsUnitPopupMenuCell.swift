//
//  EffectsUnitPopupMenuCell.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class EffectsUnitPopupMenuCell: NicerPopupMenuCell {
    
    override var cellInsetY: CGFloat {return 1}
    override var rectRadius: CGFloat {return 2}
    override var arrowXMargin: CGFloat {return 10}
    override var arrowYMargin: CGFloat {return 7}
    override var arrowColor: NSColor {return Colors.buttonMenuTextColor}
    
    override var arrowWidth: CGFloat {return 3}
    override var arrowHeight: CGFloat {return 4}
    override var arrowLineWidth: CGFloat {return 1}
    
    override var menuGradient: NSGradient {return Colors.textButtonMenuGradient}
    
    override var titleFont: NSFont {Fonts.Effects.unitFunctionFont}
    override var titleColor: NSColor {Colors.buttonMenuTextColor}
    
    override func drawTitle(_ title: NSAttributedString, withFrame: NSRect, in inView: NSView) -> NSRect {
        
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.center
        
        // Compute size and origin
        let size: CGSize = title.string.size(withFont: titleFont)
        let sx = (withFrame.width - size.width) / 2
        let sy = (withFrame.height - size.height) / 2 - 2
        
        title.string.draw(in: NSRect(x: sx, y: sy, width: size.width, height: size.height),
                          withFont: titleFont, andColor: titleColor, style: textStyle)
        
        return withFrame
    }
    
    override func titleRect(forBounds cellFrame: NSRect) -> NSRect {
        return cellFrame.offsetBy(dx: 0, dy: -1)
    }
}
