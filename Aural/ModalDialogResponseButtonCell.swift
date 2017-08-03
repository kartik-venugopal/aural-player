/*
    Customizes the look n feel of response buttons (Done, Cancel, etc) on all modal dialogs
 */

import Cocoa

class ModalDialogResponseButtonCell: NSButtonCell {
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let drawRect = cellFrame.insetBy(dx: 1, dy: 1)
        
        // Black background
        NSColor.black.setFill()
        let backgroundPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 3, yRadius: 3)
        backgroundPath.fill()
        
        let borderPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 3, yRadius: 3)
        Colors.modalDialogResponseButtonOutlineColor.setStroke()
        borderPath.lineWidth = 1.5
        borderPath.stroke()
        
        let textColor = Colors.boxTextColor
        let attrs: [String: AnyObject] = [
            NSFontAttributeName: UIConstants.modalDialogButtonFont,
            NSForegroundColorAttributeName: textColor]
        
        let size: CGSize = title!.size(withAttributes: attrs)
        let sx = (cellFrame.width - size.width) / 2
        let sy = (cellFrame.height - size.height) / 2 - 2
        
        let textRect = NSRect(x: sx, y: sy, width: size.width, height: size.height)
        title!.draw(in: textRect, withAttributes: attrs)
    }
}
