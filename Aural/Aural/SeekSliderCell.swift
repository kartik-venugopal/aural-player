/*
    Customizes the look and feel of the seek slider (which shows the current playback position) in the Now Playing section
*/

import Cocoa

class SeekSliderCell: NSSliderCell {
    
    override internal func drawKnob(knobRect: NSRect) {
        
        let drawRect = knobRect.insetBy(dx: 1.0, dy: 2.25)
        
        UIConstants.colorScheme.sliderKnobColor.setFill()
        
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 2, yRadius: 2)
        
        drawPath.fill()
        drawPath.stroke()
    }
}