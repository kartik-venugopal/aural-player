/*
 Customizes the look and feel of the parametric EQ sliders
 */

import Cocoa

class EQSliderCell: NSSliderCell {
    
    // Computes where to draw the 0db line across the middle of the bar
    fileprivate func getZeroDBLinePoints() -> (pt1: NSPoint, pt2: NSPoint) {
        
        let bar = barRect(flipped: false).insetBy(dx: 1.5, dy: 1.5)
        
        let x1 = bar.origin.x - 2.5
        let x2 = bar.origin.x + bar.width + 2.5
        let y = bar.origin.y + (bar.height / 2)
        
        let pt1 = NSPoint(x: x1, y: y), pt2 = NSPoint(x: x2, y: y)
        return (pt1, pt2)
    }
    
    override internal func drawKnob(_ knobRect: NSRect) {
        let drawRect = knobRect.insetBy(dx: 4, dy: 1)
        
        UIConstants.colorScheme.eqSliderKnobColor.setFill()
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 2, yRadius: 2)
        
        drawPath.fill()
    }
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let drawRect = aRect.insetBy(dx: 1.5, dy: 1.5)
        let knobPosition = knobRect(flipped: false)
        
        // Draw the light portion of the bar (above the knob)
        let upperRect = NSRect(x: drawRect.origin.x, y: drawRect.origin.y, width: drawRect.width, height: knobPosition.minY - drawRect.minY + 5)
        
        UIConstants.colorScheme.sliderBarLightColor.setFill()
        var drawPath = NSBezierPath.init(roundedRect: upperRect, xRadius: 2, yRadius: 2)
        drawPath.fill()
        
        // Draw the dark portion of the bar (below the knob)
        let lowerRect = NSRect(x: drawRect.origin.x, y: knobPosition.maxY - 5, width: drawRect.width, height: drawRect.maxY - knobPosition.maxY + 5)
        
        UIConstants.colorScheme.sliderBarDarkColor.setFill()
        drawPath = NSBezierPath.init(roundedRect: lowerRect, xRadius: 2, yRadius: 2)
        drawPath.fill()
        
        let zeroDbLinePoints = getZeroDBLinePoints()
        
        // Draw 0db marker line across the middle of the bar
        GraphicsUtils.drawLine(NSColor.black, pt1: zeroDbLinePoints.pt1, pt2: zeroDbLinePoints.pt2, width: 1)
    }
}
