/*
 Customizes the look and feel of the popup menus that display their selected item
 */

import Cocoa

class PreferencesPopupMenuCell: NSPopUpButtonCell {
    
    override internal func drawBorderAndBackground(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let drawRect = cellFrame.insetBy(dx: 0, dy: 5)
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 2, yRadius: 2)
        
        Colors.sliderBarGradient.draw(in: drawPath, angle: -verticalGradientDegrees)
        
        // Draw arrow
        let x = drawRect.maxX - 10, y = drawRect.maxY - 6
        GraphicsUtils.drawArrow(Colors.lightPopupMenuArrowColor, origin: NSMakePoint(x, y), dx: 3, dy: 4, lineWidth: 2)
    }
    
    override func drawTitle(_ title: NSAttributedString, withFrame: NSRect, in inView: NSView) -> NSRect {
        
        let textStyle = NSMutableParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
        
        textStyle.alignment = NSTextAlignment.center
        
        let textFontAttributes = [
            NSFontAttributeName: UIConstants.popupMenuFont,
            NSForegroundColorAttributeName: Colors.popupMenuTextColor,
            NSParagraphStyleAttributeName: textStyle
        ]
        
        title.string.draw(in: withFrame, withAttributes: textFontAttributes)
        
        return withFrame
    }
}
