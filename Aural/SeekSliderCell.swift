/*
    Customizes the look and feel of the seek slider (which shows the current playback position) in the Now Playing section
*/

import Cocoa

class SeekSliderCell: NSSliderCell {
    
    override internal func drawKnob(_ knobRect: NSRect) {
        
        let drawRect = knobRect.insetBy(dx: 1.0, dy: 2.75)
        
        UIConstants.colorScheme.sliderKnobColor.setFill()
        
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 1, yRadius: 1)
        drawPath.fill()
    }
}
