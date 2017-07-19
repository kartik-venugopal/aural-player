/*
    Customizes the look and feel of the parametric EQ sliders
*/

import Cocoa

class EQSliderCell: NSSliderCell {
    
    override internal func drawKnob(knobRect: NSRect) {
        
        let drawRect = knobRect.insetBy(dx: 4, dy: 1)
        
        UIConstants.colorScheme.eqSliderKnobColor.setFill()
        
//        let drawPath = NSBezierPath.init(rect: drawRect)
        
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 3, yRadius: 3)
        
        drawPath.fill()
    }
    
    override internal func drawBarInside(aRect: NSRect, flipped: Bool) {
        
        let drawRect = aRect.insetBy(dx: 1.5, dy: 1.5)
        
        UIConstants.colorScheme.eqSliderBarColor.setFill()
        
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 2, yRadius: 2)
        
        drawPath.fill()

    }
}