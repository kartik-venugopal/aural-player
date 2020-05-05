/*
    Provides a set of handy graphics functions that are reused across the app.
*/

import Cocoa

class GraphicsUtils {
    
    // Draws a line between 2 points
    static func drawLine(_ color: NSColor, pt1: NSPoint, pt2: NSPoint, width: CGFloat) {
        
        color.setStroke()
        
        let line = NSBezierPath() // container for line(s)
        line.move(to: pt1) // start point
        line.line(to: pt2) // destination
        line.lineWidth = width  // hair line
        line.stroke()
    }
    
    // Draws a line between 2 points
    static func drawVerticalLine(_ gradient: NSGradient, pt1: NSPoint, pt2: NSPoint, width: CGFloat) {
        
        let rect = NSRect(x: pt1.x, y: pt1.y, width: pt2.x - pt1.x + width, height: pt2.y - pt1.y + 1)

        gradient.draw(in: rect, angle: UIConstants.verticalGradientDegrees)
    }
    
    // Draws an arrow, from a given point (origin)
    static func drawArrow(_ color: NSColor, origin: NSPoint, dx: CGFloat, dy: CGFloat, lineWidth: CGFloat) {
        
        drawLine(color, pt1: origin, pt2: NSMakePoint(origin.x - dx, origin.y - dy), width: lineWidth)
        drawLine(color, pt1: origin, pt2: NSMakePoint(origin.x + dx, origin.y - dy), width: lineWidth)
    }
    
    // Draws an arrow, from a given point (origin), and fills it
    static func drawAndFillArrow(_ strokeColor: NSColor, _ fillColor: NSColor, origin: NSPoint, dx: CGFloat, dy: CGFloat) {
        
        let arrow = NSBezierPath()
        arrow.move(to: origin)
        arrow.line(to: NSMakePoint(origin.x - dx, origin.y + dy))
        arrow.line(to: NSMakePoint(origin.x + dx, origin.y + dy))
        arrow.close()
        
        strokeColor.setStroke()
        fillColor.setFill()
        
        arrow.lineWidth = 1
        arrow.fill()
        arrow.stroke()
    }
    
    // Draws text, centered, within an NSRect, with a certain font and color
    static func drawCenteredTextInRect(_ rect: NSRect, _ text: String, _ textColor: NSColor, _ font: NSFont, _ offset: CGFloat = 0) {
        
        let attrsDict: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: textColor]
        
        // Compute size and origin
        let size: CGSize = text.size(withAttributes: attrsDict)
        let sx = (rect.width - size.width) / 2
        let sy = (rect.height - size.height) / 2 - 1
        
        text.draw(in: NSRect(x: sx, y: sy + offset, width: size.width, height: size.height), withAttributes: attrsDict)
    }
    
    // Draws text, centered, within an NSRect, with a certain font and color
    static func drawTextInRect(_ rect: NSRect, _ text: String, _ textColor: NSColor, _ font: NSFont) {
        
        text.draw(in: rect, withAttributes: [
                            NSAttributedString.Key.font: font,
                            NSAttributedString.Key.foregroundColor: textColor])
    }
}
