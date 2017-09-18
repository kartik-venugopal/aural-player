/*
 Customizes the look and feel of the parametric EQ sliders
 */

import Cocoa

class EQSliderCell: NSSliderCell {
    
    override internal func drawKnob(_ knobRect: NSRect) {
        
        let rectHeight = knobRect.height
        let bar = barRect(flipped: true)
        let yCenter = knobRect.minY + (rectHeight / 2)
        
        let knobHeight: CGFloat = 13, knobWidth: CGFloat = bar.width + 2
        let knobMinY = yCenter - (knobHeight / 2)
        let rect = NSRect(x: bar.minX - ((knobWidth - bar.width) / 2), y: knobMinY, width: knobWidth, height: knobHeight)
        
        let knobPath = NSBezierPath(roundedRect: rect, xRadius: 0.5, yRadius: 0.5)
        Colors.sliderKnobColor.setFill()
        knobPath.fill()
    }
    
    override internal func drawBar(inside drawRect: NSRect, flipped: Bool) {
        
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 1, yRadius: 1)
        Colors.sliderBarGradient.draw(in: drawPath, angle: 180)
        
        // Draw one tick across the center of the bar (marking 0dB)
        let tickMinX = drawRect.minX + 1
        let tickMaxX = drawRect.maxX - 1
        
        let tickRect = rectOfTickMark(at: 0)
        let y = (tickRect.minY + tickRect.maxY) / 2
        
        GraphicsUtils.drawLine(Colors.sliderNotchColor, pt1: NSMakePoint(tickMinX, y), pt2: NSMakePoint(tickMaxX, y), width: 2)
    }
    
    override func drawTickMarks() {
        // Do nothing (ticks are drawn in drawBar)
    }
}
