/*
    Customizes the look and feel of the parametric EQ sliders
 */

import Cocoa

class EQSliderCell: NSSliderCell {
    
    let barRadius: CGFloat = 0.5
    let barInsetX: CGFloat = 0.35
    let barInsetY: CGFloat = 0
    
    let knobHeight: CGFloat = 10
    let knobInsetX: CGFloat = 1.5
    let knobInsetY: CGFloat = 0
    
    override internal func drawKnob(_ knobRect: NSRect) {
        
        let rectHeight = knobRect.height
        let bar = barRect(flipped: true).insetBy(dx: barInsetX, dy: barInsetY)
        let yCenter = knobRect.minY + (rectHeight / 2)
        
        let knobWidth: CGFloat = bar.width + 1.5
        let knobMinY = yCenter - (knobHeight / 2)
        let rect = NSRect(x: bar.minX - ((knobWidth - bar.width) / 2), y: knobMinY, width: knobWidth, height: knobHeight)
        
        let knobPath = NSBezierPath(roundedRect: rect, xRadius: 1, yRadius: 1)
        Colors.sliderKnobColor.setFill()
        knobPath.fill()
    }
    
    override internal func drawBar(inside drawRect: NSRect, flipped: Bool) {
        
        let knobFrame = knobRect(flipped: false)
        let halfKnobWidth = knobFrame.width / 2
        
        let topRect = NSRect(x: drawRect.minX, y: drawRect.minY, width: drawRect.width, height: knobFrame.minY + halfKnobWidth).insetBy(dx: barInsetX, dy: barInsetY)
        let bottomRect = NSRect(x: drawRect.minX, y: knobFrame.maxY - halfKnobWidth, width: drawRect.width, height: drawRect.height - knobFrame.maxY + halfKnobWidth).insetBy(dx: barInsetX, dy: barInsetY)
        
        // Bottom rect
        var drawPath = NSBezierPath.init(roundedRect: bottomRect, xRadius: barRadius, yRadius: barRadius)
        Colors.sliderBarColoredGradient.draw(in: drawPath, angle: -UIConstants.verticalGradientDegrees)
        
        // Top rect
        drawPath = NSBezierPath.init(roundedRect: topRect, xRadius: barRadius, yRadius: barRadius)
        Colors.sliderBarPlainGradient.draw(in: drawPath, angle: -UIConstants.verticalGradientDegrees)
        
        // Draw one tick across the center of the bar (marking 0dB)
        let tickMinX = drawRect.minX + 1.5
        let tickMaxX = drawRect.maxX - 1.5
        
        let tickRect = rectOfTickMark(at: 0)
        let y = (tickRect.minY + tickRect.maxY) / 2
        
        // Tick
        GraphicsUtils.drawLine(NSColor.black, pt1: NSMakePoint(tickMinX, y), pt2: NSMakePoint(tickMaxX, y), width: 2)
    }
    
    override func drawTickMarks() {
        // Do nothing (ticks are drawn in drawBar)
    }
}
