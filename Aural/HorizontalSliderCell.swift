/*
    Customizes the look and feel of all horizontal sliders
*/

import Cocoa

class HorizontalSliderCell: NSSliderCell {
    
    override internal func drawKnob(_ knobRect: NSRect) {
        
        let drawRect = knobRect.insetBy(dx: 1.75, dy: 3.75)

        UIConstants.colorScheme.sliderKnobColor.setFill()
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 1.5, yRadius: 1.5)
        drawPath.fill()
    }
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let drawRect = aRect.insetBy(dx: 0, dy: -0.25)
        
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 1.5, yRadius: 1.5)
        UIConstants.sliderBarGradient.draw(in: drawPath, angle: -verticalGradientDegrees)
    }
}
