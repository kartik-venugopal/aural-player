/*
    Customizes the look and feel of all non-ticked horizontal sliders
*/

import Cocoa

// Base class for all horizontal slider cells
class HorizontalSliderCell: NSSliderCell {
    
    var barRadius: CGFloat {return 1}
    var barPlainGradient: NSGradient {return Colors.sliderBarPlainGradient}
    var barColoredGradient: NSGradient {return Colors.sliderBarColoredGradient}
    var barInsetX: CGFloat {return 0}
    var barInsetY: CGFloat {return 0}
    
    var knobWidth: CGFloat {return 10}
    var knobHeightOutsideBar: CGFloat {return 2}
    var knobRadius: CGFloat {return 1}
    var knobColor: NSColor {return Colors.sliderKnobColor}
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let knobFrame = knobRect(flipped: false)
        let halfKnobWidth = knobFrame.width / 2
        
        let leftRect = NSRect(x: aRect.minX, y: aRect.minY, width: max(halfKnobWidth, knobFrame.minX + halfKnobWidth), height: aRect.height)

        var drawPath = NSBezierPath.init(roundedRect: leftRect, xRadius: barRadius, yRadius: barRadius)
        barPlainGradient.draw(in: drawPath, angle: -UIConstants.verticalGradientDegrees)
        
        let rightRect = NSRect(x: knobFrame.maxX - halfKnobWidth, y: aRect.minY, width: aRect.width - knobFrame.minX, height: aRect.height)
        
        drawPath = NSBezierPath.init(roundedRect: rightRect, xRadius: barRadius, yRadius: barRadius)
        barColoredGradient.draw(in: drawPath, angle: -UIConstants.verticalGradientDegrees)
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

// Cell for volume slider
class VolumeSliderCell: HorizontalSliderCell {
    
    override var knobWidth: CGFloat {return 7}
    override var knobRadius: CGFloat {return 0.5}
    override var knobHeightOutsideBar: CGFloat {return 1}
}

// Cell for seek position slider
class SeekSliderCell: HorizontalSliderCell {
    
    override var barRadius: CGFloat {return 0.5}
    override var barInsetY: CGFloat {return 0.5}
    override var knobRadius: CGFloat {return 0.5}
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let drawPath = NSBezierPath.init(roundedRect: aRect, xRadius: barRadius, yRadius: barRadius)
        barPlainGradient.draw(in: drawPath, angle: -UIConstants.verticalGradientDegrees)
    }
}

// Cell for sliders on the Preferences panel
class PreferencesSliderCell: HorizontalSliderCell {
    
    override var barRadius: CGFloat {return 1.5}
    override var barInsetY: CGFloat {return -1}
}

// Cell for sliders on the effects panel
class EffectsSliderCell: HorizontalSliderCell {
    
    override var barRadius: CGFloat {return 1.5}
    override var barInsetY: CGFloat {return -1}
    override var knobRadius: CGFloat {return 1}
    override var knobHeightOutsideBar: CGFloat {return 1}
}
