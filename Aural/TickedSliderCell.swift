/*
    Customizes the look and feel of the Time stretch slider
*/

import Cocoa

class TickedSliderCell: NSSliderCell {
    
    // Top and bottom of tick
    fileprivate static let tickMinY: CGFloat = 20
    fileprivate static let tickMaxY: CGFloat = 25
    
    override internal func drawKnob(_ knobRect: NSRect) {
        
        let rectWidth = knobRect.maxX - knobRect.minX, rectHeight = knobRect.maxY - knobRect.minY
        
        let x = knobRect.minX + (rectWidth / 2), y: CGFloat = rectHeight

        GraphicsUtils.drawAndFillArrow(UIConstants.colorScheme.sliderKnobColor, origin: NSMakePoint(x, y), dx: rectWidth / 5, dy: rectHeight - 8)
    }
    
    // Draws slider bar and ticks
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let drawRect = aRect.insetBy(dx: 1.5, dy: 1.5)
        let knobPosition = knobRect(flipped: false)
        
        // Draw the dark portion of the bar (left of the knob)
        let leftRect = NSRect(x: drawRect.origin.x, y: drawRect.origin.y, width: knobPosition.minX - drawRect.minX + 6, height: drawRect.height)
        
        UIConstants.colorScheme.sliderBarDarkColor.setFill()
        var drawPath = NSBezierPath.init(roundedRect: leftRect, xRadius: 2, yRadius: 2)
        drawPath.fill()
        
        // Draw the light portion of the bar (right of the knob)
        let rightRect = NSRect(x: knobPosition.maxX - 6, y: drawRect.origin.y, width: drawRect.maxX - knobPosition.maxX + 6, height: drawRect.height)
        
        UIConstants.colorScheme.sliderBarLightColor.setFill()
        drawPath = NSBezierPath.init(roundedRect: rightRect, xRadius: 2, yRadius: 2)
        drawPath.fill()
        
        // Calculate width of drawing rect for ticks
        let rectMinX = drawRect.origin.x + 6
        let rectMaxX = drawRect.origin.x + drawRect.width - 6
        let width = rectMaxX - rectMinX
        
        // Draw 16 ticks
        for i in 0...15 {
            
            let x = rectMinX + (CGFloat(i) * width / 15)
            
            GraphicsUtils.drawLine(NSColor.black, pt1: NSMakePoint(x, TickedSliderCell.tickMinY), pt2: NSMakePoint(x, TickedSliderCell.tickMaxY), width: 1)
        }
    }
}
