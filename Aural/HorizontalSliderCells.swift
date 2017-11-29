/*
    Customizes the look and feel of all non-ticked horizontal sliders
*/

import Cocoa

// Base class for all horizontal slider cells
class HorizontalSliderCell: NSSliderCell {
    
    var barRadius: CGFloat {return 1}
    var barPlainGradient: NSGradient {return Colors.sliderBarPlainGradient}
    var barColoredGradient: NSGradient {return Colors.sliderBarColoredGradient}
    var gradientDegrees: CGFloat {return UIConstants.horizontalGradientDegrees}
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
        barColoredGradient.draw(in: drawPath, angle: gradientDegrees)
        
        let rightRect = NSRect(x: knobFrame.maxX - halfKnobWidth, y: aRect.minY, width: aRect.width - (knobFrame.maxX - halfKnobWidth), height: aRect.height)
        
        drawPath = NSBezierPath.init(roundedRect: rightRect, xRadius: barRadius, yRadius: barRadius)
        barPlainGradient.draw(in: drawPath, angle: gradientDegrees)
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
    
    override var barInsetY: CGFloat {return 0.25}
    override var knobWidth: CGFloat {return 6}
    override var knobRadius: CGFloat {return 0.5}
    override var knobHeightOutsideBar: CGFloat {return 0.5}
}

// Cell for seek position slider
class SeekSliderCell: HorizontalSliderCell {
    
    override var barRadius: CGFloat {return 1}
    override var barInsetY: CGFloat {return 1.5}
    
    override var knobRadius: CGFloat {return 0}
    override var knobColor: NSColor {return NSColor(white: 0.8, alpha: 1.0)}
    override var knobWidth: CGFloat {return 7}
    override var knobHeightOutsideBar: CGFloat {return 2}
    
    override var barPlainGradient: NSGradient {return Colors.seekBarPlainGradient}
    override var barColoredGradient: NSGradient {return Colors.seekBarColoredGradient}
}

class BarModeSeekSliderCell: HorizontalSliderCell {
    
    override var barRadius: CGFloat {return 1}
    override var barInsetY: CGFloat {return 0.5}
    
    override var knobRadius: CGFloat {return 0}
    override var knobColor: NSColor {return NSColor(white: 0.8, alpha: 1.0)}
    override var knobWidth: CGFloat {return 5}
    override var knobHeightOutsideBar: CGFloat {return 1}
    
    override var barPlainGradient: NSGradient {return Colors.seekBarPlainGradient}
    override var barColoredGradient: NSGradient {return Colors.seekBarColoredGradient}
}


// Cell for sliders on the Preferences panel
class PreferencesSliderCell: HorizontalSliderCell {
    
    override var barRadius: CGFloat {return 1.5}
    override var barInsetY: CGFloat {return 0.5}
}

// Cell for sliders on the effects panel
class EffectsSliderCell: HorizontalSliderCell {

    override var barRadius: CGFloat {return 1.5}
    override var barInsetY: CGFloat {return 0.5}
    
    override var knobWidth: CGFloat {return 8}
    override var knobRadius: CGFloat {return 1}
    override var knobHeightOutsideBar: CGFloat {return 1}
}
