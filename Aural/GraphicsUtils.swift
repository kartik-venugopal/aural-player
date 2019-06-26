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
        arrow.line(to: NSMakePoint(origin.x - dx, origin.y - dy))
        arrow.line(to: NSMakePoint(origin.x + dx, origin.y - dy))
        arrow.close()
        
        strokeColor.setStroke()
        fillColor.setFill()
        
        arrow.lineWidth = 1
        arrow.fill()
        arrow.stroke()
    }
    
    // Draws text, centered, within an NSRect, with a certain font and color
    static func drawCenteredTextInRect(_ rect: NSRect, _ text: String, _ textColor: NSColor, _ font: NSFont) {
        
        let attrs: [String: AnyObject] = [
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): font,
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): textColor]
        
        // Compute size and origin
        let attrsDict = convertToOptionalNSAttributedStringKeyDictionary(attrs)
        let size: CGSize = text.size(withAttributes: attrsDict)
        let sx = (rect.width - size.width) / 2
        let sy = (rect.height - size.height) / 2 - 1
        
        text.draw(in: NSRect(x: sx, y: sy, width: size.width, height: size.height), withAttributes: attrsDict)
    }
    
    // Draws text, centered, within an NSRect, with a certain font and color
    static func drawTextInRect(_ rect: NSRect, _ text: String, _ textColor: NSColor, _ font: NSFont) {
        
        let attrs: [String: AnyObject] = [
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): font,
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): textColor]
        
        // Compute size and origin
        text.draw(in: rect, withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attrs))
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
