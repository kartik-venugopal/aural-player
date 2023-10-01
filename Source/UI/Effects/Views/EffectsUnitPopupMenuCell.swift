//
//  EffectsUnitPopupMenuCell.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class EffectsUnitPopupMenuCell: NicerPopupMenuCell {
    
    override var cellInsetY: CGFloat {1}
    override var rectRadius: CGFloat {2}
    override var arrowXMargin: CGFloat {10}
    override var arrowYMargin: CGFloat {7}
    override var arrowColor: NSColor {Colors.buttonMenuTextColor}
    
    override var arrowWidth: CGFloat {3}
    override var arrowHeight: CGFloat {4}
    override var arrowLineWidth: CGFloat {1}
    
    override var menuGradient: NSGradient {Colors.textButtonMenuGradient}
    
    override var titleFont: NSFont {Fonts.Effects.unitFunctionFont}
    override var titleColor: NSColor {Colors.buttonMenuTextColor}
    
    override func drawTitle(_ title: NSAttributedString, withFrame: NSRect, in inView: NSView) -> NSRect {
        
        title.string.drawCentered(in: withFrame,
                                  withFont: titleFont, andColor: titleColor, yOffset: -1)
        
        return withFrame
    }
    
    override func titleRect(forBounds cellFrame: NSRect) -> NSRect {cellFrame}
}
