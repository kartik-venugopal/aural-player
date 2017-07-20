/*
    Customizes the look and feel of the volume slider
*/

import Cocoa

class HorizontalSliderCell: NSSliderCell {
    
    override internal func drawKnob(_ knobRect: NSRect) {
        
        let drawRect = knobRect.insetBy(dx: 1.5, dy: 3)
        
        UIConstants.colorScheme.sliderKnobColor.setFill()
        
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 2, yRadius: 2)
        
        drawPath.fill()
        drawPath.stroke()
    }
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let drawRect = aRect.insetBy(dx: 1, dy: 1)
        
        UIConstants.colorScheme.eqSliderBarColor.setFill()
        
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 2, yRadius: 2)
        
        drawPath.fill()
        
    }
}
