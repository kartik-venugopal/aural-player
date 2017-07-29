/*
    Customizes the look and feel of all non-ticked horizontal sliders
*/

import Cocoa

class EffectsSliderCell: NSSliderCell {
    
    override internal func drawKnob(_ knobRect: NSRect) {
        
        let drawRect = knobRect.insetBy(dx: 1.75, dy: 3.75)

        Colors.sliderKnobColor.setFill()
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 1.5, yRadius: 1.5)
        drawPath.fill()
    }
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let drawRect = aRect.insetBy(dx: 0, dy: -0.25)
        
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 1.5, yRadius: 1.5)
        Colors.sliderBarGradient.draw(in: drawPath, angle: -verticalGradientDegrees)
    }
}

class VolumeSliderCell: NSSliderCell {
    
    private let verticalGradientDegrees: CGFloat = 90.0
    
    override internal func drawKnob(_ knobRect: NSRect) {
        
        let drawRect = knobRect.insetBy(dx: 2, dy: 3.25)
        
        Colors.lightSliderKnobColor.setFill()
        let drawPath = NSBezierPath.init(rect: drawRect)
        
        drawPath.fill()
    }
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let drawRect = aRect.insetBy(dx: 0, dy: 0)
        
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 1, yRadius: 1)
        Colors.sliderBarGradient.draw(in: drawPath, angle: -verticalGradientDegrees)
    }
}

class SeekSliderCell: NSSliderCell {
    
    override internal func drawKnob(_ knobRect: NSRect) {
        
        let drawRect = knobRect.insetBy(dx: 1.5, dy: 3.5)
        
        Colors.sliderKnobColor.setFill()
        
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 1, yRadius: 1)
        drawPath.fill()
    }
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let drawRect = aRect.insetBy(dx: 0, dy: -0.75)
        
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 1.5, yRadius: 1.5)
        Colors.sliderBarGradient.draw(in: drawPath, angle: -90)
    }
}
