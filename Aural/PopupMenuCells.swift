/*
    Customizes the look and feel of the popup menus that display their selected item
*/

import Cocoa

class PopupMenuCell: NSPopUpButtonCell {
    
    var cellInsetX: CGFloat {return 0}
    var cellInsetY: CGFloat {return 0}
    var rectRadius: CGFloat {return 1}
    var menuGradient: NSGradient {return Colors.sliderBarGradient}
    
    var titleFont: NSFont {return UIConstants.popupMenuFont}
    var titleColor: NSColor {return Colors.popupMenuTextColor}
    
    var arrowXMargin: CGFloat {return 5}
    var arrowYMargin: CGFloat {return 5}
    var arrowWidth: CGFloat {return 3}
    var arrowHeight: CGFloat {return 3}
    var arrowLineWidth: CGFloat {return 2}
    var arrowColor: NSColor {return Colors.popupMenuArrowColor}
    
    override internal func drawBorderAndBackground(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let drawRect = cellFrame.insetBy(dx: cellInsetX, dy: cellInsetY)
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: rectRadius, yRadius: rectRadius)
        
        menuGradient.draw(in: drawPath, angle: -UIConstants.verticalGradientDegrees)
        
        // Draw arrow
        let x = drawRect.maxX - arrowXMargin, y = drawRect.maxY - arrowYMargin
        GraphicsUtils.drawArrow(arrowColor, origin: NSMakePoint(x, y), dx: arrowWidth, dy: arrowHeight, lineWidth: arrowLineWidth)
    }
    
    override func drawTitle(_ title: NSAttributedString, withFrame: NSRect, in inView: NSView) -> NSRect {
        
        let textStyle = NSMutableParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.center
        
        let textFontAttributes = [
            NSFontAttributeName: titleFont,
            NSForegroundColorAttributeName: titleColor,
            NSParagraphStyleAttributeName: textStyle
        ]
        
        title.string.draw(in: withFrame, withAttributes: textFontAttributes)
        
        return withFrame
    }
}

// Reverb and Recorder format menus
class ReverbPopupMenuCell: PopupMenuCell {
    
    override var cellInsetY: CGFloat {return 4}
    override var rectRadius: CGFloat {return 2}
    override var arrowXMargin: CGFloat {return 10}
    override var arrowYMargin: CGFloat {return 4}
    override var arrowHeight: CGFloat {return 4}
}

class RecorderFormatPopupMenuCell: ReverbPopupMenuCell {
}

class PreferencesPopupMenuCell: PopupMenuCell {
    
    override var cellInsetY: CGFloat {return 5}
    override var rectRadius: CGFloat {return 2}
    override var arrowXMargin: CGFloat {return 10}
    override var arrowYMargin: CGFloat {return 6}
    override var arrowHeight: CGFloat {return 4}
    override var arrowColor: NSColor {return Colors.lightPopupMenuArrowColor}
}

class EQPopupMenuCell: PopupMenuCell {
    
    override var cellInsetX: CGFloat {return 9}
    override var cellInsetY: CGFloat {return 3}
    override var rectRadius: CGFloat {return 2}
    override var arrowXMargin: CGFloat {return 8}
    override var arrowYMargin: CGFloat {return 4}
    override var arrowHeight: CGFloat {return 4}
    
    override
    func drawTitle(_ title: NSAttributedString, withFrame: NSRect, in inView: NSView) -> NSRect {
        
        // Don't draw the title (we don't need it)
        return withFrame
    }
}
