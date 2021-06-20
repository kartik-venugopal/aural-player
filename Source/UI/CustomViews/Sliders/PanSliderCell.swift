import Cocoa

// Cell for pan slider
class PanSliderCell: TickedSliderCell {
    
    override var barRadius: CGFloat {1}
    override var barInsetY: CGFloat {SystemUtils.isBigSur ? 0 : 0.5}
    
    override var knobWidth: CGFloat {6}
    override var knobRadius: CGFloat {0.5}
    override var knobHeightOutsideBar: CGFloat {1.5}
    
    // Draw entire bar with single gradient
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        var drawPath = NSBezierPath.init(roundedRect: aRect, xRadius: barRadius, yRadius: barRadius)
        backgroundGradient.draw(in: drawPath, angle: .horizontalGradientDegrees)
        
        drawTicks(aRect)
        
        // Draw rect between knob and center, to show panning
        let knobCenter = knobRect(flipped: false).centerX
        let barCenter = aRect.centerX
        let panRectX = min(knobCenter, barCenter)
        let panRectWidth = abs(knobCenter - barCenter)
        
        if panRectWidth > 0 {
            
            let panRect = NSRect(x: panRectX, y: aRect.minY, width: panRectWidth, height: aRect.height)
            drawPath = NSBezierPath.init(roundedRect: panRect, xRadius: barRadius, yRadius: barRadius)
            
            if doubleValue > 0 {
                foregroundGradient.draw(in: drawPath, angle: -.horizontalGradientDegrees)
            } else {
                foregroundGradient.reversed().draw(in: drawPath, angle: -.horizontalGradientDegrees)
            }
        }
    }
    
    override func knobRect(flipped: Bool) -> NSRect {
        
        let bar = barRect(flipped: flipped)
        let val = CGFloat(self.doubleValue)
        let perc: CGFloat = 50 + (val / 2)
        
        let startX = bar.minX + perc * bar.width / 100
        let xOffset = -(perc * knobWidth / 100)
        
        let newX = startX + xOffset
        let newY = bar.minY - knobHeightOutsideBar
        
        return NSRect(x: newX, y: newY, width: knobWidth, height: knobHeightOutsideBar * 2 + bar.height)
    }
}
