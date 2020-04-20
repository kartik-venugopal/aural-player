import Cocoa

// TODO: Make this more reusable
class ProgressArc: NSView {
    
    var percentage: Double = 0 {
        
        didSet {
            self.redraw()
        }
    }
    
    var radius: CGFloat = 30
    var lineWidth: CGFloat = 4
    
    let backColor: NSColor = Colors.Constants.white20Percent
    var textFont: NSFont = Fonts.progressArcFont
    
    override func draw(_ dirtyRect: NSRect) {
        
        let p0: NSPoint = NSPoint(x: dirtyRect.width / 2, y: dirtyRect.height / 2)

        let backgroundCirclePath: NSBezierPath = NSBezierPath()
        backgroundCirclePath.appendArc(withCenter: p0, radius: radius, startAngle: 0, endAngle: 360, clockwise: false)
        backColor.setStroke()
        backgroundCirclePath.lineWidth = lineWidth
        backgroundCirclePath.stroke()
        
        // Clear any previously added sublayers (otherwise, previously drawn arcs will remain)
        layer?.sublayers?.removeAll()
   
        // Add a gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = dirtyRect
        gradientLayer.colors = [NSColor.white.cgColor, NSColor.lightGray.cgColor]
        
        layer?.addSublayer(gradientLayer)
        
        // Create a mask in the shape of arc
        let mask = CAShapeLayer()
        mask.frame = dirtyRect
        mask.lineWidth = lineWidth
        mask.strokeColor = NSColor.gray.cgColor
        
        let arcPath = NSBezierPath()
        
        // To prevent the arc from disappearing when we hit 100%
        if percentage >= 100 {percentage = 99.98}
        
        let endAngle: CGFloat = 540 - (CGFloat(percentage) * 3.6)
        arcPath.appendArc(withCenter: p0, radius: radius, startAngle: 180, endAngle: endAngle, clockwise: true)
        
        mask.fillColor = NSColor.clear.cgColor
        mask.lineCap = CAShapeLayerLineCap.round
        mask.path = arcPath.CGPath
        
        // Add the mask to the gradient layer
        gradientLayer.mask = mask
        
        // ---------------------- PERCENTAGE TEXT ----------------------
        
        let text = String(format: "%d %%", Int(round(percentage)))
        
        let attrs: [String: AnyObject] = [
            NSAttributedString.Key.font.rawValue: textFont,
            NSAttributedString.Key.foregroundColor.rawValue: NSColor.white]
        
        let dict = convertToOptionalNSAttributedStringKeyDictionary(attrs)
        
        let size: CGSize = text.size(withAttributes: dict)
        
        // Draw title (adjacent to image)
        text.draw(in: NSRect(x: (dirtyRect.width / 2) - (size.width / 2) + 2, y: (dirtyRect.height / 2) - (size.height / 2) + 2, width: size.width, height: size.height), withAttributes: dict)
    }
}

fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
