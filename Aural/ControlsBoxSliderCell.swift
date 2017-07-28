/*
 Customizes the look and feel of all horizontal sliders
 */

import Cocoa

class ControlsBoxSliderCell: NSSliderCell {
    
    private let verticalGradientDegrees: CGFloat = 90.0
    
    override internal func drawKnob(_ knobRect: NSRect) {
        
        let drawRect = knobRect.insetBy(dx: 2, dy: 3.25)
        
        UIConstants.colorScheme.lightSliderKnobColor.setFill()
        let drawPath = NSBezierPath.init(rect: drawRect)
        
        drawPath.fill()
    }
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let drawRect = aRect.insetBy(dx: 0, dy: 0)
        
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 1, yRadius: 1)
        UIConstants.sliderBarGradient.draw(in: drawPath, angle: -verticalGradientDegrees)
    }
}
