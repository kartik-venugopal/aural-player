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
        
        let drawRect = knobRect.insetBy(dx: 3.75, dy: 1)
        
        Colors.eqSliderKnobColor.setFill()
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 1.5, yRadius: 1.5)
        drawPath.fill()
    }
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let drawRect = aRect.insetBy(dx: 0, dy: 0)
        
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 1, yRadius: 1)
        Colors.sliderBarGradient.draw(in: drawPath, angle: 180)
        
        let zeroDbLinePoints = getZeroDBLinePoints()
        
        // Draw 0db marker line across the middle of the bar
        GraphicsUtils.drawLine(NSColor.black, pt1: zeroDbLinePoints.pt1, pt2: zeroDbLinePoints.pt2, width: 2)
    }
}
