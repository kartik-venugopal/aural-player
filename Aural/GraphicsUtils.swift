/*
    Provides a set of handy graphics functions that are reused across the app.
*/

import Cocoa

class GraphicsUtils {
    
    // Draws a line between 2 points
    static func drawLine(color: NSColor, pt1: NSPoint, pt2: NSPoint, width: CGFloat) {
        
        color.setStroke()
        
        let line = NSBezierPath() // container for line(s)
        line.moveToPoint(pt1) // start point
        line.lineToPoint(pt2) // destination
        line.lineWidth = width  // hair line
        line.stroke()
    }
    
    // Draws an arrow, from a given point (origin)
    static func drawArrow(color: NSColor, origin: NSPoint, dx: CGFloat, dy: CGFloat, lineWidth: CGFloat) {
        
        drawLine(color, pt1: origin, pt2: NSMakePoint(origin.x - dx, origin.y - dy), width: lineWidth)
        drawLine(color, pt1: origin, pt2: NSMakePoint(origin.x + dx, origin.y - dy), width: lineWidth)
    }
    
    // Draws an arrow, from a given point (origin), and fills it
    static func drawAndFillArrow(color: NSColor, origin: NSPoint, dx: CGFloat, dy: CGFloat) {
        
        let arrow = NSBezierPath()
        arrow.moveToPoint(origin)
        arrow.lineToPoint(NSMakePoint(origin.x - dx, origin.y - dy))
        arrow.lineToPoint(NSMakePoint(origin.x + dx, origin.y - dy))
        arrow.closePath()
        
        color.setStroke()
        color.setFill()
        
        arrow.stroke()
        arrow.fill()
    }
}