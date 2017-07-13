/*
    Customizes the look and feel of the Time stretch slider
*/

import Cocoa

class TickedSliderCell: NSSliderCell {
    
    override internal func drawKnob(knobRect: NSRect) {
        
        let rectWidth = knobRect.maxX - knobRect.minX, rectHeight = knobRect.maxY - knobRect.minY
        
        let x = knobRect.minX + (rectWidth / 2), y: CGFloat = rectHeight

        GraphicsUtils.drawAndFillArrow(UIConstants.colorScheme.sliderKnobColor, origin: NSMakePoint(x, y), dx: rectWidth / 5, dy: rectHeight - 8)
    }
}