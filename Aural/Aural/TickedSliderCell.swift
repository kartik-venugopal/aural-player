/*
    Customizes the look and feel of the pitch and balance (ticked) sliders
*/

import Cocoa

class TickedSliderCell: NSSliderCell {
    
    override internal func drawKnob(knobRect: NSRect) {
        
        let drawRect = knobRect.insetBy(dx: 1, dy: 2.5)
        
        UIConstants.colorScheme.sliderKnobColor.setFill()
        
        let drawPath = NSBezierPath.init(rect: drawRect)
        
        drawPath.fill()
        drawPath.stroke()
    }
}