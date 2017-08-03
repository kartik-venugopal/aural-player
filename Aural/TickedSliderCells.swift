/*
 Customizes the look and feel of all ticked horizonatl sliders
 */

import Cocoa

class PanSliderCell: NSSliderCell {
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let drawPath = NSBezierPath.init(roundedRect: aRect, xRadius: 1, yRadius: 1)
        Colors.sliderBarGradient.draw(in: drawPath, angle: -verticalGradientDegrees)
        
        let ticksCount = self.numberOfTickMarks
        let tickMinY = aRect.minY + 1
        let tickMaxY = aRect.maxY - 1
        
        for i in 1...ticksCount - 2 {
            
            let tickRect = rectOfTickMark(at: i)
            let x = (tickRect.minX + tickRect.maxX) / 2
            
            GraphicsUtils.drawLine(Colors.effectsSliderNotchColor, pt1: NSMakePoint(x, tickMinY), pt2: NSMakePoint(x, tickMaxY), width: 2)
        }
    }
    
    override func drawTickMarks() {
        // Do nothing (ticks are drawn in drawBar)
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

class EffectsTickedSliderCell: EffectsSliderCell {
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        super.drawBar(inside: aRect, flipped: flipped)
        
        let ticksCount = self.numberOfTickMarks
        let tickMinY = aRect.minY + 1.5
        let tickMaxY = aRect.maxY - 1.5
        
        if (ticksCount > 2) {
            
            for i in 1...ticksCount - 2 {
                
                let tickRect = rectOfTickMark(at: i)
                let x = (tickRect.minX + tickRect.maxX) / 2
                
                GraphicsUtils.drawLine(Colors.effectsSliderNotchColor, pt1: NSMakePoint(x, tickMinY), pt2: NSMakePoint(x, tickMaxY), width: 1.5)
            }
        } else if (ticksCount == 1) {
            
            let tickRect = rectOfTickMark(at: 0)
            let x = (tickRect.minX + tickRect.maxX) / 2
            
            GraphicsUtils.drawLine(Colors.effectsSliderNotchColor, pt1: NSMakePoint(x, tickMinY), pt2: NSMakePoint(x, tickMaxY), width: 2)
        }
    }
    
    override func drawTickMarks() {
        // Do nothing (ticks are drawn in drawBar)
    }
}

class EffectsSliderCell: NSSliderCell {
    
    override internal func drawKnob(_ knobRect: NSRect) {
        
        let rectWidth = knobRect.width
        let bar = barRect(flipped: true)
        let xCenter = knobRect.minX + (rectWidth / 2)
        
        let knobWidth: CGFloat = 10, knobHeight: CGFloat = bar.height + 1
        
        let knobMinX = xCenter - (knobWidth / 2)
        let rect = NSRect(x: knobMinX, y: bar.minY - ((knobHeight - bar.height) / 2), width: knobWidth, height: knobHeight)
        
        let knobPath = NSBezierPath(roundedRect: rect, xRadius: 1, yRadius: 1)
        Colors.sliderKnobColor.setFill()
        knobPath.fill()
    }
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let drawPath = NSBezierPath.init(roundedRect: aRect, xRadius: 1.5, yRadius: 1.5)
        Colors.sliderBarGradient.draw(in: drawPath, angle: -verticalGradientDegrees)
    }
    
    override func barRect(flipped: Bool) -> NSRect {
        return super.barRect(flipped: flipped).insetBy(dx: 0, dy: -1)
    }
}
