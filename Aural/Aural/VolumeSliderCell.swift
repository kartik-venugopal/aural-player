/*
    Customizes the look and feel of the volume slider
*/

import Cocoa

class HorizontalSliderCell: NSSliderCell {
    
    override internal func drawKnob(knobRect: NSRect) {
        
        let drawRect = knobRect.insetBy(dx: 1.5, dy: 3)
        
        UIConstants.colorScheme.sliderKnobColor.setFill()
        
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 2, yRadius: 2)
        
        drawPath.fill()
        drawPath.stroke()
    }
}