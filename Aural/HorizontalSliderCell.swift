/*
    Customizes the look and feel of all horizontal sliders
*/

import Cocoa

class HorizontalSliderCell: NSSliderCell {
    
    // Size ranges for slider width
    static let sliderWidth_small: (min: CGFloat, max: CGFloat) = (50, 75)
    static let sliderWidth_medium: (min: CGFloat, max: CGFloat) = (76, 100)
    static let sliderWidth_large: (min: CGFloat, max: CGFloat) = (100, 150)
    
    // Different knob insets for small/medium/large sliders ... larger the slider, smaller the inset
    static let knobInset_small: (dx: CGFloat, dy: CGFloat) = (1.75, 3.5)
    static let knobInset_medium: (dx: CGFloat, dy: CGFloat) = (1.625, 3.25)
    static let knobInset_large: (dx: CGFloat, dy: CGFloat) = (1.5, 3)
    
    // Used to draw the knob
    fileprivate var knobInset: (dx: CGFloat, dy: CGFloat) = HorizontalSliderCell.knobInset_medium
    
    override init() {
        super.init()
        knobInset = getKnobInsetForSliderWidth()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        knobInset = getKnobInsetForSliderWidth()
    }
    
    // Calculates knob inset based on slider width
    fileprivate func getKnobInsetForSliderWidth() -> (dx: CGFloat, dy: CGFloat) {
        
        let bar = barRect(flipped: false)
        
        // Small
        if (bar.width >= HorizontalSliderCell.sliderWidth_small.min && bar.width <= HorizontalSliderCell.sliderWidth_small.max) {
            return HorizontalSliderCell.knobInset_small
        }
        
        // Medium
        if (bar.width >= HorizontalSliderCell.sliderWidth_medium.min && bar.width <= HorizontalSliderCell.sliderWidth_medium.max) {
            return HorizontalSliderCell.knobInset_medium
        }
        
        // Large
        return HorizontalSliderCell.knobInset_large
    }
    
    override internal func drawKnob(_ knobRect: NSRect) {
        
        let drawRect = knobRect.insetBy(dx: knobInset.dx, dy: knobInset.dy)
        
        UIConstants.colorScheme.sliderKnobColor.setFill()
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: 1, yRadius: 1)
        
        drawPath.fill()
    }
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let drawRect = aRect.insetBy(dx: 1, dy: 1)
        let knobPosition = knobRect(flipped: false)
        
        // Draw the dark portion of the bar (to the left of the knob)
        let leftRect = NSRect(x: drawRect.origin.x, y: drawRect.origin.y, width: knobPosition.minX - drawRect.minX + 2.5, height: drawRect.height)
        
        UIConstants.colorScheme.sliderBarDarkColor.setFill()
        var drawPath = NSBezierPath.init(roundedRect: leftRect, xRadius: 2, yRadius: 2)
        drawPath.fill()
        
        // Draw the light portion of the bar (to the right of the knob)
        let rightRect = NSRect(x: knobPosition.maxX - 2.5, y: drawRect.origin.y, width: drawRect.maxX - knobPosition.maxX + 2.5, height: drawRect.height)
        
        UIConstants.colorScheme.sliderBarLightColor.setFill()
        drawPath = NSBezierPath.init(roundedRect: rightRect, xRadius: 2, yRadius: 2)
        drawPath.fill()
    }
}
