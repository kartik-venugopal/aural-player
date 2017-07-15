/*
    Customizes the look and feel of the popup menu for EQ presets
*/

import Cocoa

class EQPopupMenuCell: NSPopUpButtonCell {
    
    override internal func drawBorderAndBackground(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let frameWidth = cellFrame.width
        let rectWidth: CGFloat = 16
        let drawRect = cellFrame.insetBy(dx: (frameWidth - rectWidth) / 2, dy: 4)
        
        UIConstants.colorScheme.popupMenuColor.setFill()
        
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 3, yRadius: 3)
        
        drawPath.fill()
        
        // Draw arrow
        let x = drawRect.maxX - (rectWidth / 2), y = drawRect.maxY - 5
        GraphicsUtils.drawArrow(NSColor.black, origin: NSMakePoint(x, y), dx: 3, dy: 3, lineWidth: 1)
    }
    
    override
    func drawTitle(_ title: NSAttributedString, withFrame: NSRect, in inView: NSView) -> NSRect {
        
        // Don't draw the title (we don't need it)
        return withFrame
    }
}
