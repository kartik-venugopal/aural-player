/*
 Customizes the look and feel of buttons that control the preferences panel's tab view
 */

import Cocoa

class PrefsTabButtonCell: NSButtonCell {
    
    // Highlighting colors the button text to indicate that the effects unit represented by this button is currently active
    var shouldHighlight: Bool = false
    var highlightColor: NSColor = Colors.tabViewButtonTextColor
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        // Draw border
        let drawRect = cellFrame.insetBy(dx: 1, dy: 1)
        let roundedPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 4, yRadius: 4)
        Colors.tabViewButtonOutlineColor.setStroke()
        roundedPath.lineWidth = 1
        roundedPath.stroke()
        
        // If selected, fill in the rect
        if (self.state == 1) {
            NSColor.black.setFill()
            roundedPath.fill()
        }
        
        // Draw the title
        let textColor = state == 0 ? Colors.tabViewButtonTextColor : NSColor.white
        
        let attrs: [String: AnyObject] = [
            NSFontAttributeName: UIConstants.tabViewButtonFont,
            NSForegroundColorAttributeName: textColor]
        
        let size: CGSize = title!.size(withAttributes: attrs)
        let sx = (cellFrame.width - size.width) / 2
        let sy = (cellFrame.height - size.height) / 2 - 2
        
        let textRect = NSRect(x: sx, y: sy, width: size.width, height: size.height)
        title!.draw(in: textRect, withAttributes: attrs)
    }
}
