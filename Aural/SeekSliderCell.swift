/*
    Customizes the look and feel of the seek slider (which shows the current playback position) in the Now Playing section
*/

import Cocoa

class SeekSliderCell: NSSliderCell {
    
    override internal func drawKnob(_ knobRect: NSRect) {
        
        let drawRect = knobRect.insetBy(dx: 1.5, dy: 3.5)
        
        UIConstants.colorScheme.sliderKnobColor.setFill()
        
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 1, yRadius: 1)
        drawPath.fill()
    }
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let drawRect = aRect.insetBy(dx: 0, dy: -0.75)
        
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 1, yRadius: 1)
        UIConstants.sliderBarGradient.draw(in: drawPath, angle: -90)
    }
}
