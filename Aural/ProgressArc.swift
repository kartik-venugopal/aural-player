import Cocoa

class ProgressArc: NSView {
    
    var perc: Double = 0 {
        
        didSet {
            self.redraw()
        }
    }
    
    var textFont: NSFont = Fonts.progressBarFont
    
    var radius: CGFloat = 30
    
    var barColoredGradient: NSGradient {return Colors.progressBarColoredGradient}
    var gradientDegrees: CGFloat {return UIConstants.horizontalGradientDegrees}
    
    var barRadius: CGFloat {return 1.3}
    var barInsetX: CGFloat {return 0}
    var barInsetY: CGFloat {return 8}
    
    let backColor: NSColor = NSColor(calibratedWhite: 0.2, alpha: 1)
    
    override func draw(_ dirtyRect: NSRect) {
        
        let p0: NSPoint = NSPoint(x: dirtyRect.width / 2, y: dirtyRect.height / 2)

        let backgroundCirclePath: NSBezierPath = NSBezierPath()
        backgroundCirclePath.appendArc(withCenter: p0, radius: radius, startAngle: 0, endAngle: 360, clockwise: false)
        backColor.setStroke()
        backgroundCirclePath.lineWidth = 5
        backgroundCirclePath.stroke()
        
        layer?.sublayers?.removeAll()
   
        //Add gradient layer
        let gl = CAGradientLayer()
        gl.frame = dirtyRect
        gl.colors = [NSColor.white.cgColor, NSColor.white.cgColor]
        layer?.addSublayer(gl)
        
        //create mask in the shape of arc
        let sl = CAShapeLayer()
        sl.frame = dirtyRect
        sl.lineWidth = 5.0
        sl.strokeColor = NSColor.white.cgColor
        
        let path = NSBezierPath()
        
        if perc == 100 {perc = 99.95}
        let endAngle: CGFloat = 540 - (CGFloat(perc) * 3.6)
        path.appendArc(withCenter: p0, radius: radius, startAngle: 180, endAngle: endAngle, clockwise: true)
        
        sl.fillColor = NSColor.clear.cgColor
        sl.lineCap = CAShapeLayerLineCap.round
        sl.path = path.CGPath
        
        //Add mask to gradient layer
        gl.mask = sl
        
        // ---------------------- PERCENTAGE TEXT ----------------------
        
        let text = String(format: "%d %%", Int(round(perc)))
        
        let attrs: [String: AnyObject] = [
            NSAttributedString.Key.font.rawValue: textFont,
            NSAttributedString.Key.foregroundColor.rawValue: NSColor.white]
        
        let dict = convertToOptionalNSAttributedStringKeyDictionary(attrs)
        
        let size: CGSize = text.size(withAttributes: dict)
        
        // Draw title (adjacent to image)
        text.draw(in: NSRect(x: (dirtyRect.width / 2) - (size.width / 2), y: (dirtyRect.height / 2) - (size.height / 2) + 2, width: size.width, height: size.height), withAttributes: dict)
    }
}

fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
