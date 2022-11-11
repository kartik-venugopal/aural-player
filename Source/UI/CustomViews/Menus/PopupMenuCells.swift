//
//  PopupMenuCells.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
    Customizes the look and feel of all popup menus
*/

import Cocoa

// Base class for all popup menu cells
class PopupMenuCell: NSPopUpButtonCell {
    
    var cellInsetX: CGFloat {0}
    var cellInsetY: CGFloat {0}
    var rectRadius: CGFloat {1}
    var menuGradient: NSGradient {.sliderBarGradient}
    
    var titleFont: NSFont {.popupMenuFont}
    var titleColor: NSColor {Colors.Effects.defaultPopupMenuTextColor}
    
    var arrowXMargin: CGFloat {5}
    var arrowYMargin: CGFloat {5}
    var arrowWidth: CGFloat {3}
    var arrowHeight: CGFloat {3}
    var arrowLineWidth: CGFloat {2}
    var arrowColor: NSColor {.popupMenuArrowColor}
    
    var textOffsetX: CGFloat {0}
    var textOffsetY: CGFloat {0}
    
    override internal func drawBorderAndBackground(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let drawRect = cellFrame.insetBy(dx: cellInsetX, dy: cellInsetY)
        NSBezierPath.fillRoundedRect(drawRect, radius: rectRadius, withGradient: menuGradient, angle: -.verticalGradientDegrees)
        
        // Draw arrow
        let x = drawRect.maxX - arrowXMargin, y = drawRect.maxY - arrowYMargin
        GraphicsUtils.drawArrow(arrowColor, origin: NSMakePoint(x, y), dx: arrowWidth, dy: arrowHeight, lineWidth: arrowLineWidth)
    }
    
    override func drawTitle(_ title: NSAttributedString, withFrame: NSRect, in inView: NSView) -> NSRect {
        
        title.string.draw(in: withFrame.offsetBy(dx: textOffsetX, dy: textOffsetY), withFont: titleFont,
                          andColor: titleColor, style: .centeredText)
        
        return withFrame
    }
}

// Cell for reverb preset popup menu
class NicerPopupMenuCell: PopupMenuCell {
    
    override var cellInsetY: CGFloat {4}
    override var rectRadius: CGFloat {2}
    override var arrowXMargin: CGFloat {10}
    override var arrowYMargin: CGFloat {4}
    override var arrowHeight: CGFloat {4}
}

class FontsPopupMenuCell: PopupMenuCell {
    
    override var cellInsetY: CGFloat {2}
    override var rectRadius: CGFloat {2}
    override var arrowXMargin: CGFloat {10}
    override var arrowYMargin: CGFloat {6}
    override var arrowHeight: CGFloat {6}
    override var arrowColor: NSColor {.lightPopupMenuArrowColor}
    
    override var menuGradient: NSGradient {.popupMenuGradient}
    
    override var textOffsetY: CGFloat {3}
}

class EffectsPreviewPopupMenuCell: NicerPopupMenuCell {
    
    override var menuGradient: NSGradient {Colors.Effects.defaultPopupMenuGradient}
    
    override var titleColor: NSColor {Colors.Effects.defaultPopupMenuTextColor}
    
    override var arrowColor: NSColor {titleColor}
    
    override var textOffsetY: CGFloat {-1}
}
