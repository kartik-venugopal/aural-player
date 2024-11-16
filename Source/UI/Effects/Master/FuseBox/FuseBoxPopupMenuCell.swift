//
//  FuseBoxPopupMenuCell.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class FuseBoxPopupMenuCell: NSButtonCell {
    
    var cellInsetY: CGFloat {1}
    var rectRadius: CGFloat {2}
    var arrowXMargin: CGFloat {20}
    var arrowYMargin: CGFloat {7}
    
    var imageWidth: CGFloat {36}
    var imageHeight: CGFloat {30}
    
    var tintColor: NSColor = systemColorScheme.buttonColor {
        
        didSet {
            redraw()
        }
    }
    
    var arrowWidth: CGFloat {5}
    var arrowHeight: CGFloat {8}
    var arrowLineWidth: CGFloat {1.5}
    
    var titleFont: NSFont {systemFontScheme.prominentFont}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        image?.isTemplate = true
    }
    
    override func drawTitle(_ title: NSAttributedString, withFrame: NSRect, in inView: NSView) -> NSRect {
        
        title.string.drawCentered(in: withFrame,
                                  withFont: titleFont, andColor: tintColor, xOffset: 12, yOffset: 1)
        
        return withFrame
    }
    
    override func drawImage(_ image: NSImage, withFrame frame: NSRect, in controlView: NSView) {
        
        let btnFrame = controlView.frame
        let y = (btnFrame.height - imageHeight) / 2
        
        image.tintedWithColor(tintColor).draw(in: NSMakeRect(20, y, imageWidth, imageHeight))
    }
    
    override func drawBezel(withFrame frame: NSRect, in controlView: NSView) {
        
        NSBezierPath.strokeRoundedRect(frame.insetBy(dx: 0.5, dy: 0.5), radius: rectRadius, withColor: tintColor)
        
        // Draw arrow
        let x = frame.maxX - arrowXMargin - arrowWidth, y = frame.maxY - ((frame.height - arrowHeight) / 2) + 1
        GraphicsUtils.drawArrow(tintColor, origin: NSMakePoint(x, y), dx: arrowWidth, dy: arrowHeight, lineWidth: arrowLineWidth)
    }
    
    override func titleRect(forBounds cellFrame: NSRect) -> NSRect {cellFrame}
}

extension FuseBoxPopupMenuCell: FXUnitStateObserver {
    
    func redraw() {
        controlView?.redraw()
    }

    func unitStateChanged(to newState: EffectsUnitState) {
        
        tintColor = systemColorScheme.colorForEffectsUnitState(newState)
        (controlView as? NSButton)?.contentTintColor = tintColor
    }
}
