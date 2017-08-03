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
    
    // Draws an arrow, from a given point (origin)
    static func drawArrow(_ color: NSColor, origin: NSPoint, dx: CGFloat, dy: CGFloat, lineWidth: CGFloat) {
        
        drawLine(color, pt1: origin, pt2: NSMakePoint(origin.x - dx, origin.y - dy), width: lineWidth)
        drawLine(color, pt1: origin, pt2: NSMakePoint(origin.x + dx, origin.y - dy), width: lineWidth)
    }
    
    // Draws an arrow, from a given point (origin), and fills it
    static func drawAndFillArrow(_ strokeColor: NSColor, _ fillColor: NSColor, origin: NSPoint, dx: CGFloat, dy: CGFloat) {
        
        let arrow = NSBezierPath()
        arrow.move(to: origin)
        arrow.line(to: NSMakePoint(origin.x - dx, origin.y - dy))
        arrow.line(to: NSMakePoint(origin.x + dx, origin.y - dy))
        arrow.close()
        
        strokeColor.setStroke()
        fillColor.setFill()
        
        arrow.lineWidth = 1
        arrow.fill()
        arrow.stroke()
    }
    
    static func drawText(_ text: String, _ origin: NSPoint, _ textColor: NSColor, _ font: NSFont) {
        
        let attrs: [String: AnyObject] = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: textColor]
        
        let size: CGSize = text.size(withAttributes: attrs)
        let sx = origin.x
        let sy = origin.y
        
        let textRect = NSRect(x: sx, y: sy, width: size.width, height: size.height)
        text.draw(in: textRect, withAttributes: attrs)
    }
}
