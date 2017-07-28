/*
    Customizes the look and feel of the Time stretch slider
*/

import Cocoa

class TickedSliderCell: NSSliderCell {
    
    override internal func drawKnob(_ knobRect: NSRect) {
        
        let rectWidth = knobRect.maxX - knobRect.minX, rectHeight = knobRect.maxY - knobRect.minY
        
        let bar = barRect(flipped: false).insetBy(dx: 1.5, dy: 0)
        let yDiff = knobRect.maxY - bar.maxY
        
        let x = knobRect.minX + (rectWidth / 2), y: CGFloat = rectHeight - 1

        GraphicsUtils.drawAndFillArrow(UIConstants.colorScheme.timeSliderKnobStrokeColor, UIConstants.colorScheme.timeSliderKnobColor, origin: NSMakePoint(x, y), dx: rectWidth / 3, dy: rectHeight - yDiff - 2)
    }
}

class TimeSliderCell: TickedSliderCell {
    
    // Top and bottom of tick
    private static let tickMinY: CGFloat = 20
    private static let tickMaxY: CGFloat = 25
    
    // Draws slider bar and ticks
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let drawRect = aRect.insetBy(dx: 1.5, dy: 0)
        
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 1, yRadius: 1)
        UIConstants.sliderBarGradient.draw(in: drawPath, angle: -verticalGradientDegrees)
        
        // Calculate width of drawing rect for ticks
        let rectMinX = drawRect.origin.x + 6
        let rectMaxX = drawRect.origin.x + drawRect.width - 6
        let width = rectMaxX - rectMinX
        
        // Draw 16 ticks
        for i in 0...15 {
            
            let x = rectMinX + (CGFloat(i) * width / 15)
            
            GraphicsUtils.drawLine(UIConstants.colorScheme.boxTextColor, pt1: NSMakePoint(x, TimeSliderCell.tickMinY), pt2: NSMakePoint(x, TimeSliderCell.tickMaxY), width: 1)
        }
    }
}

class PanSliderCell: TickedSliderCell {
    
    // Draws slider bar and ticks
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let drawRect = aRect.insetBy(dx: 0, dy: 0)
        
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 1, yRadius: 1)
        UIConstants.sliderBarGradient.draw(in: drawPath, angle: -verticalGradientDegrees)
        
        // Calculate width of drawing rect for ticks
        let rectMinX = drawRect.origin.x
        let rectMaxX = drawRect.origin.x + drawRect.width
        let width = rectMaxX - rectMinX
        
        // Draw center tick
        let x = rectMinX + (width / 2)
        
        let tickMinY: CGFloat = 11, tickMaxY: CGFloat = 15
            
        GraphicsUtils.drawLine(UIConstants.colorScheme.boxTextColor, pt1: NSMakePoint(x, tickMinY), pt2: NSMakePoint(x, tickMaxY), width: 1)
    }
}
