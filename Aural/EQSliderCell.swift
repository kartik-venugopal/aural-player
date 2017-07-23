/*
 Customizes the look and feel of the parametric EQ sliders
 */

import Cocoa

class EQSliderCell: NSSliderCell {
    
    override internal func drawKnob(_ knobRect: NSRect) {
        let drawRect = knobRect.insetBy(dx: 3.5, dy: 1)
        
        UIConstants.colorScheme.eqSliderKnobColor.setFill()
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 2, yRadius: 2)
        
        drawPath.fill()
    }
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let drawRect = aRect.insetBy(dx: 1.5, dy: 1.5)
        
        let knobPosition = knobRect(flipped: false)
        
        let upperRect = NSRect(x: drawRect.origin.x, y: drawRect.origin.y, width: drawRect.width, height: knobPosition.minY - drawRect.minY + 5)
        
        // Draw the light portion of the bar (above the knob)
        UIConstants.colorScheme.sliderBarLightColor.setFill()
        var drawPath = NSBezierPath.init(roundedRect: upperRect, xRadius: 2, yRadius: 2)
        drawPath.fill()
        
        // Draw the dark portion of the bar (below the knob)
        let lowerRect = NSRect(x: drawRect.origin.x, y: knobPosition.maxY - 5, width: drawRect.width, height: drawRect.maxY - knobPosition.maxY + 5)
        
        UIConstants.colorScheme.sliderBarDarkColor.setFill()
        drawPath = NSBezierPath.init(roundedRect: lowerRect, xRadius: 2, yRadius: 2)
        drawPath.fill()
    }
}
