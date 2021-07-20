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
        
        title.string.drawCentered(in: withFrame,
                                  withFont: titleFont, andColor: titleColor)
        
        return withFrame
    }
    
    override func titleRect(forBounds cellFrame: NSRect) -> NSRect {
        return cellFrame.offsetBy(dx: 0, dy: -1)
    }
}
