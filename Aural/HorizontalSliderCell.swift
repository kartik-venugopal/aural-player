/*
    Customizes the look and feel of all horizontal sliders
*/

import Cocoa

class HorizontalSliderCell: NSSliderCell {
    
    override internal func drawKnob(_ knobRect: NSRect) {
        
        let drawRect = knobRect.insetBy(dx: 1.5, dy: 3)
        
        UIConstants.colorScheme.sliderKnobColor.setFill()
        
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 1, yRadius: 1)
        
        drawPath.fill()
        drawPath.stroke()
    }
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let drawRect = aRect.insetBy(dx: 1, dy: 1)
        let knobPosition = knobRect(flipped: false)
        
        // Draw the dark portion of the bar (to the left of the knob)
        let leftRect = NSRect(x: drawRect.origin.x, y: drawRect.origin.y, width: knobPosition.minX - drawRect.minX + 2.5, height: drawRect.height)
        
        UIConstants.colorScheme.sliderBarDarkColor.setFill()
        var drawPath = NSBezierPath.init(roundedRect: leftRect, xRadius: 2, yRadius: 2)
        drawPath.fill()
        
        // Draw the light portion of the bar (to the right of the knob)
        let rightRect = NSRect(x: knobPosition.maxX - 2.5, y: drawRect.origin.y, width: drawRect.maxX - knobPosition.maxX + 2.5, height: drawRect.height)
        
        UIConstants.colorScheme.sliderBarLightColor.setFill()
        drawPath = NSBezierPath.init(roundedRect: rightRect, xRadius: 2, yRadius: 2)
        drawPath.fill()
    }
}
