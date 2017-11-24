/*
    Customizes the look and feel of all ticked horizontal sliders
 */

import Cocoa

// Base class for all ticked horizontal slider cells
class TickedSliderCell: HorizontalSliderCell {
    
    var tickVerticalSpacing: CGFloat {return 1}
    var tickWidth: CGFloat {return 2}
    var tickColor: NSColor {return Colors.sliderNotchColor}
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        super.drawBar(inside: aRect, flipped: flipped)
        drawTicks(aRect)
    }
    
    internal func drawTicks(_ aRect: NSRect) {
        
        // Draw ticks (as notches, within the bar)
        let ticksCount = self.numberOfTickMarks
        
        if (ticksCount > 2) {
            
            for i in 1...ticksCount - 2 {
                drawTick(i, aRect)
            }
            
        } else if (ticksCount == 1) {
            drawTick(0, aRect)
        }
    }
    
    // Draws a single tick within a bar
    internal func drawTick(_ index: Int, _ barRect: NSRect) {
        
        let tickMinY = barRect.minY + tickVerticalSpacing
        let tickMaxY = barRect.maxY - tickVerticalSpacing
        
        let tickRect = rectOfTickMark(at: index)
        let x = (tickRect.minX + tickRect.maxX) / 2
        
        GraphicsUtils.drawLine(tickColor, pt1: NSMakePoint(x, tickMinY), pt2: NSMakePoint(x, tickMaxY), width: tickWidth)
    }
    
    override func drawTickMarks() {
        // Do nothing (ticks are drawn in drawBar)
    }
}

// Cell for pan slider
class PanTickedSliderCell: TickedSliderCell {
    
    override var barInsetY: CGFloat {return 0.25}
    override var barRadius: CGFloat {return 1}
    
    override var knobWidth: CGFloat {return 6}
    override var knobRadius: CGFloat {return 0.5}
    override var knobHeightOutsideBar: CGFloat {return 0.5}
    
    // Draw entire bar with single gradient
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let drawPath = NSBezierPath.init(roundedRect: aRect, xRadius: barRadius, yRadius: barRadius)
        barPlainGradient.draw(in: drawPath, angle: -UIConstants.verticalGradientDegrees)
        
        drawTicks(aRect)
    }
}

// Cell for all ticked effects sliders
class EffectsTickedSliderCell: TickedSliderCell {
    
    override var barRadius: CGFloat {return 1.5}
    override var barInsetY: CGFloat {return 0.5}
    
    override var knobWidth: CGFloat {return 8}
    override var knobRadius: CGFloat {return 1}
    override var knobHeightOutsideBar: CGFloat {return 1}
    
    override var tickVerticalSpacing: CGFloat {return 1}
    override var tickColor: NSColor {return NSColor.black}
}
