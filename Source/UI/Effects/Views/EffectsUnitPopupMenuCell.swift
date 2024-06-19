//
//  EffectsUnitPopupMenuCell.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
    
    var tintColor: NSColor = systemColorScheme.buttonColor {
        
        didSet {
            redraw()
        }
    }
    
    override var arrowWidth: CGFloat {3}
    override var arrowHeight: CGFloat {4}
    override var arrowLineWidth: CGFloat {1}
    
    override var titleFont: NSFont {systemFontScheme.normalFont}
//    override var titleColor: NSColor {Colors.buttonMenuTextColor}
    
    override func drawTitle(_ title: NSAttributedString, withFrame: NSRect, in inView: NSView) -> NSRect {
        
        title.string.drawCentered(in: withFrame,
                                  withFont: titleFont, andColor: tintColor, yOffset: 1)
        
        return withFrame
    }
    
    override internal func drawBorderAndBackground(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let drawRect = cellFrame.insetBy(dx: cellInsetX, dy: cellInsetY)
        NSBezierPath.strokeRoundedRect(drawRect.insetBy(dx: 0.5, dy: 0.5), radius: rectRadius, withColor: tintColor)
        
        // Draw arrow
        let x = drawRect.maxX - arrowXMargin, y = drawRect.maxY - arrowYMargin
        GraphicsUtils.drawArrow(tintColor, origin: NSMakePoint(x, y), dx: arrowWidth, dy: arrowHeight, lineWidth: arrowLineWidth)
    }
    
    override func titleRect(forBounds cellFrame: NSRect) -> NSRect {cellFrame}
}

extension EffectsUnitPopupMenuCell: FXUnitStateObserver {

    func unitStateChanged(to newState: EffectsUnitState) {
        tintColor = systemColorScheme.colorForEffectsUnitState(newState)
    }
}
