/*
    Customizes the look and feel of all non-ticked horizontal sliders
*/

import Cocoa

// Base class for all horizontal slider cells
class HorizontalSliderCell: NSSliderCell {
    
    // TODO: Apply logic from SeekSliderCell.drawKnob and knobRect here in this class (so that all sliders can benefit from it)
    
    var barRadius: CGFloat {1}
    
    var backgroundGradient: NSGradient {Colors.Player.sliderBackgroundGradient}
    var foregroundGradient: NSGradient {Colors.Player.sliderForegroundGradient}
    var gradientDegrees: CGFloat {.horizontalGradientDegrees}
    
    var barInsetX: CGFloat {0}
    var barInsetY: CGFloat {0}
    
    var knobWidth: CGFloat {10}
    var knobHeightOutsideBar: CGFloat {2}
    var knobRadius: CGFloat {1}
    var knobColor: NSColor {Colors.Player.sliderKnobColor}
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let knobFrame = knobRect(flipped: false)
        let halfKnobWidth = knobFrame.width / 2
        
        let leftRect = NSRect(x: aRect.minX, y: aRect.minY, width: max(halfKnobWidth, knobFrame.minX + halfKnobWidth), height: aRect.height)

        var drawPath = NSBezierPath.init(roundedRect: leftRect, xRadius: barRadius, yRadius: barRadius)
        foregroundGradient.draw(in: drawPath, angle: gradientDegrees)
        
        let rightRect = NSRect(x: knobFrame.maxX - halfKnobWidth, y: aRect.minY, width: aRect.width - (knobFrame.maxX - halfKnobWidth), height: aRect.height)
        
        drawPath = NSBezierPath.init(roundedRect: rightRect, xRadius: barRadius, yRadius: barRadius)
        backgroundGradient.draw(in: drawPath, angle: gradientDegrees)
    }
    
    override internal func drawKnob(_ knobRect: NSRect) {
        
        let rectWidth = knobRect.width
        let bar = barRect(flipped: true)
        let xCenter = knobRect.minX + (rectWidth / 2)
        
        let knobHeight: CGFloat = bar.height + knobHeightOutsideBar
        let knobMinX = xCenter - (knobWidth / 2)
        let rect = NSRect(x: knobMinX, y: bar.minY - ((knobHeight - bar.height) / 2), width: knobWidth, height: knobHeight)
        
        let knobPath = NSBezierPath(roundedRect: rect, xRadius: knobRadius, yRadius: knobRadius)
        knobColor.setFill()
        knobPath.fill()
    }
    
    override func barRect(flipped: Bool) -> NSRect {
        return super.barRect(flipped: flipped).insetBy(dx: barInsetX, dy: barInsetY)
    }
}
