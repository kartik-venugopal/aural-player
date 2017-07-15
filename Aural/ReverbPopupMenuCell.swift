/*
    Customizes the look and feel of the popup menu for the reverb setting
*/

import Cocoa

class ReverbPopupMenuCell: NSPopUpButtonCell {

    override internal func drawBorderAndBackground(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let drawRect = cellFrame.insetBy(dx: 0, dy: 2.5)
        
        UIConstants.colorScheme.popupMenuColor.setFill()
        
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 5, yRadius: 5)
        
        drawPath.fill()
        
        // Draw arrow
        let x = drawRect.maxX - 10, y = drawRect.maxY - 5
        GraphicsUtils.drawArrow(NSColor.black, origin: NSMakePoint(x, y), dx: 3, dy: 4, lineWidth: 1)
        
    }
    
    override func drawTitle(_ title: NSAttributedString, withFrame: NSRect, in inView: NSView) -> NSRect {
        
        let textStyle = NSMutableParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
        
        textStyle.alignment = NSTextAlignment.center
        
        let textFontAttributes = [
            NSFontAttributeName: UIConstants.reverbMenuFont,
            NSForegroundColorAttributeName: UIConstants.colorScheme.playlistSelectedTextColor,
            NSParagraphStyleAttributeName: textStyle
        ]
        
        title.string.draw(in: NSOffsetRect(withFrame, 0, -1), withAttributes: textFontAttributes)
        
        return withFrame
    }
}
