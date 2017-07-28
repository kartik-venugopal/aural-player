import Cocoa

class ColoredToggleButtonCell: NSButtonCell {
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {

        // Black background
        NSColor.black.setFill()
        let backgroundPath = NSBezierPath.init(rect: cellFrame)
        backgroundPath.fill()
        
        // Draw border
        let drawRect = cellFrame.insetBy(dx: 1, dy: 1)
        
        let roundedPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 2, yRadius: 2)
        UIConstants.colorScheme.tabViewOutlineColor.setStroke()
        roundedPath.lineWidth = 1.5
        roundedPath.stroke()
        
        // If selected, fill in the rect
        if (self.state == 1) {
            let roundedPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 2, yRadius: 2)
            UIConstants.colorScheme.tabViewSelectionBoxColor.setFill()
            roundedPath.fill()
        }
        
        // Draw the title
        let textColor = state == 0 ? UIConstants.colorScheme.tabViewTextColor : UIConstants.colorScheme.playlistSelectedTextColor
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
