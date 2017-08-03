/*
    Customizes the look and feel of all non-ticked horizontal sliders
*/

import Cocoa

class VolumeSliderCell: NSSliderCell {
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let drawPath = NSBezierPath.init(roundedRect: aRect, xRadius: 1, yRadius: 1)
        Colors.sliderBarGradient.draw(in: drawPath, angle: -verticalGradientDegrees)
    }
    
    override internal func drawKnob(_ knobRect: NSRect) {
        
        let rectWidth = knobRect.width
        let bar = barRect(flipped: true)
        let xCenter = knobRect.minX + (rectWidth / 2)
        
        let knobWidth: CGFloat = 7, knobHeight: CGFloat = bar.height + 1
        let knobMinX = xCenter - (knobWidth / 2)
        let rect = NSRect(x: knobMinX, y: bar.minY - ((knobHeight - bar.height) / 2), width: knobWidth, height: knobHeight)
        
        let knobPath = NSBezierPath(roundedRect: rect, xRadius: 0.5, yRadius: 0.5)
        Colors.sliderKnobColor.setFill()
        knobPath.fill()
    }
}

class SeekSliderCell: NSSliderCell {
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let drawPath = NSBezierPath.init(roundedRect: aRect, xRadius: 0.5, yRadius: 0.5)
        Colors.sliderBarGradient.draw(in: drawPath, angle: -verticalGradientDegrees)
    }
    
    override internal func drawKnob(_ knobRect: NSRect) {
        
        let rectWidth = knobRect.width
        let bar = barRect(flipped: true)
        let xCenter = knobRect.minX + (rectWidth / 2)
        
        let knobWidth: CGFloat = 10, knobHeight: CGFloat = bar.height + 2
        let knobMinX = xCenter - (knobWidth / 2)
        let rect = NSRect(x: knobMinX, y: bar.minY - ((knobHeight - bar.height) / 2), width: knobWidth, height: knobHeight)
        
        let knobPath = NSBezierPath(roundedRect: rect, xRadius: 0.5, yRadius: 0.5)
        Colors.sliderKnobColor.setFill()
        knobPath.fill()
    }
    
    override func barRect(flipped: Bool) -> NSRect {
        return super.barRect(flipped: flipped).insetBy(dx: 0, dy: 0.5)
    }
}
