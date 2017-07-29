/*
    Customizes the look and feel of the popup menu for EQ presets
*/

import Cocoa

class EQPopupMenuCell: NSPopUpButtonCell {
    
    override internal func drawBorderAndBackground(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let frameWidth = cellFrame.width
        let rectWidth: CGFloat = 16
        let drawRect = cellFrame.insetBy(dx: (frameWidth - rectWidth) / 2, dy: 3)
        
        Colors.popupMenuColor.setFill()
        
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 2, yRadius: 2)
        drawPath.fill()
        
        // Draw arrow
        let arrowWidth: CGFloat = 3, arrowHeight: CGFloat = 3
        let x = drawRect.maxX - (rectWidth / 2), y = drawRect.origin.y + (drawRect.maxY / 2) + (arrowHeight / 2) - 1
        GraphicsUtils.drawArrow(NSColor.black, origin: NSMakePoint(x, y), dx: arrowWidth, dy: arrowHeight, lineWidth: 1)
    }
    
    override
    func drawTitle(_ title: NSAttributedString, withFrame: NSRect, in inView: NSView) -> NSRect {
        
        // Don't draw the title (we don't need it)
        return withFrame
    }
}
