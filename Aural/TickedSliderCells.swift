/*
    Customizes the look and feel of all ticked horizontal sliders
 */

import Cocoa

// Base class for all ticked horizontal slider cells
class TickedSliderCell: HorizontalSliderCell {
    
    var tickVerticalSpacing: CGFloat {return 1}
    var tickWidth: CGFloat {return 3}
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
    
    override var barRadius: CGFloat {return 2}
    override var barInsetY: CGFloat {return 1}
    override var knobWidth: CGFloat {return 7}
    override var knobRadius: CGFloat {return 1.5}
    override var knobHeightOutsideBar: CGFloat {return 4}
    
    // Draw entire bar with single gradient
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let offsetRect = aRect.offsetBy(dx: 0, dy: 0.25)
        
        var drawPath = NSBezierPath.init(roundedRect: offsetRect, xRadius: barRadius, yRadius: barRadius)
        barPlainGradient.draw(in: drawPath, angle: -UIConstants.verticalGradientDegrees)
        
        drawTicks(aRect)
        
        // Draw rect between knob and center, to show panning
        let knobCenter = knobRect(flipped: false).centerX
        let barCenter = offsetRect.centerX
        let panRectX = min(knobCenter, barCenter)
        let panRectWidth = abs(knobCenter - barCenter)
        
        if panRectWidth > 0 {
            
            let panRect = NSRect(x: panRectX, y: offsetRect.minY, width: panRectWidth, height: offsetRect.height)
            drawPath = NSBezierPath.init(roundedRect: panRect, xRadius: barRadius, yRadius: barRadius)
            barColoredGradient.draw(in: drawPath, angle: -UIConstants.verticalGradientDegrees)
        }
    }
}

// Cell for all ticked effects sliders
class EffectsTickedSliderCell: TickedSliderCell, EffectsUnitSliderCellProtocol {
    
    override var barRadius: CGFloat {return 1}
    override var barInsetY: CGFloat {return 0.5}
    
    override var knobWidth: CGFloat {return 10}
    override var knobRadius: CGFloat {return 2}
    override var knobHeightOutsideBar: CGFloat {return 5}
    
    override var knobColor: NSColor {
        
        switch self.unitState {
            
        case .active:   return Colors.activeKnobColor
            
        case .bypassed: return Colors.bypassedKnobColor
            
        case .suppressed:   return Colors.suppressedKnobColor
            
        }
    }
    
    override var tickVerticalSpacing: CGFloat {return 0.75}
    
    override var barColoredGradient: NSGradient {
     
        switch self.unitState {
            
        case .active:   return Colors.activeSliderBarColoredGradient
            
        case .bypassed: return Colors.bypassedSliderBarColoredGradient
            
        case .suppressed:   return Colors.suppressedSliderBarColoredGradient
            
        }
    }
    
    var unitState: EffectsUnitState = .bypassed
}
