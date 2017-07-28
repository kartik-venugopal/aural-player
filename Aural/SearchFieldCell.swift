import Cocoa

class SearchFieldCell: NSSearchFieldCell {
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
//        self.backgroundColor = NSColor.black
//        self.drawsBackground = true
//        self.textColor = UIConstants.colorScheme.boxTextColor
//        self.draw
//        (self.controlView as! NSSearchField).cursor
        
        super.drawInterior(withFrame: cellFrame, in: controlView)
//        
//        let drawRect = cellFrame.insetBy(dx: 1, dy: 1)
//        
//        // Black background
//        NSColor.black.setFill()
//        let backgroundPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 3, yRadius: 3)
//        backgroundPath.fill()
//        
//        let borderPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 3, yRadius: 3)
//        UIConstants.colorScheme.sliderKnobColor.setStroke()
//        borderPath.lineWidth = 1.5
//        borderPath.stroke()
//        
//        let textColor = UIConstants.colorScheme.boxTextColor
//        let attrs: [String: AnyObject] = [
//            NSFontAttributeName: UIConstants.modalDialogButtonFont,
//            NSForegroundColorAttributeName: textColor]
//        
//        let text = self.stringValue
//        
//        let size: CGSize = text.size(withAttributes: attrs)
////        let sx = (cellFrame.width - size.width) / 2
//        let sx: CGFloat = 0
//        let sy = (cellFrame.height - size.height) / 2 - 2
//        
//        let textRect = NSRect(x: sx, y: sy, width: size.width, height: size.height)
//        text.draw(in: textRect, withAttributes: attrs)
    }
    
//    open func draw(withFrame cellFrame: NSRect, in controlView: NSView)
}
