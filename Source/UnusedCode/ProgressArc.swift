//import Cocoa

// TODO: Make this more reusable, clean it up
/*
    Displays task progress as a circular arc, with progress percentage displayed inside the arc.
 */
//class ProgressArc: NSView {
//
//    var percentage: Double = 0 {
//
//        didSet {
//            self.redraw()
//        }
//    }
//
//    var radius: CGFloat = 30
//
//    var lineWidth: CGFloat = 4
//
//    var backgroundColor: NSColor {return Colors.Player.progressArcBackgroundColor}
//    var foregroundColor: NSColor {return Colors.Player.sliderForegroundColor}
//
//    var textFont: NSFont {return FontSchemes.systemScheme.player.infoBoxArtistAlbumFont}
//
//    override func awakeFromNib() {
//        radius = (self.width - (2 * lineWidth)) / 2
//    }
//
//    override func draw(_ dirtyRect: NSRect) {
//
//        let p0: NSPoint = NSPoint(x: dirtyRect.width / 2, y: dirtyRect.height / 2)
//
//        let backgroundCirclePath: NSBezierPath = NSBezierPath()
//        backgroundCirclePath.appendArc(withCenter: p0, radius: radius, startAngle: 0, endAngle: 360, clockwise: false)
//        backgroundColor.setStroke()
//        backgroundCirclePath.lineWidth = lineWidth
//        backgroundCirclePath.stroke()
//
//        let arcPath = NSBezierPath()
//
//        // To prevent the arc from disappearing when we hit 100%
//        if percentage >= 100 {percentage = 99.98}
//
//        let endAngle: CGFloat = 540 - (CGFloat(percentage) * 3.6)
//        arcPath.appendArc(withCenter: p0, radius: radius, startAngle: 180, endAngle: endAngle, clockwise: true)
//
//        foregroundColor.setStroke()
//        arcPath.lineWidth = lineWidth
//        arcPath.stroke()
//
//        // Clear any previously added sublayers (otherwise, previously drawn arcs will remain)
////        layer?.sublayers?.removeAll()
//
//        // Add a gradient layer
////        let gradientLayer = CAGradientLayer()
////        gradientLayer.frame = dirtyRect
////        gradientLayer.colors = [NSColor.white.cgColor, NSColor.lightGray.cgColor]
//////        gradientLayer.colors = [NSColor.red, NSColor.red.darkened(50)]
////
////        print("FC:", foregroundColor.toString())
////
////        layer?.addSublayer(gradientLayer)
////
////        // Create a mask in the shape of an arc
////        let mask = CAShapeLayer()
////        mask.frame = dirtyRect
////        mask.lineWidth = lineWidth
//////        mask.strokeColor = NSColor.gray.cgColor
////        mask.strokeColor = foregroundColor.cgColor
////
////        let arcPath = NSBezierPath()
////
////        // To prevent the arc from disappearing when we hit 100%
////        if percentage >= 100 {percentage = 99.98}
////
////        let endAngle: CGFloat = 540 - (CGFloat(percentage) * 3.6)
////        arcPath.appendArc(withCenter: p0, radius: radius, startAngle: 180, endAngle: endAngle, clockwise: true)
////
////        mask.fillColor = NSColor.clear.cgColor
////        mask.lineCap = CAShapeLayerLineCap.round
////        mask.path = arcPath.CGPath
////
////        // Add the mask to the gradient layer
////        gradientLayer.mask = mask
//
//        // ---------------------- PERCENTAGE TEXT ----------------------
//
//        let text = String(format: "%d %%", Int(round(percentage)))
//
//        let dict: [NSAttributedString.Key: Any] = [
//            NSAttributedString.Key.font: textFont,
//            NSAttributedString.Key.foregroundColor: Colors.Player.progressArcTextColor]
//
//        let size: CGSize = text.size(withAttributes: dict)
//
//        // Draw title (adjacent to image)
//        text.draw(in: NSRect(x: (dirtyRect.width / 2) - (size.width / 2) + 2, y: (dirtyRect.height / 2) - (size.height / 2) + 2, width: size.width, height: size.height), withAttributes: dict)
//    }
//}
