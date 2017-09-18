/*
    Customizes the look and feel of all non-ticked horizontal sliders
*/

import Cocoa

class HorizontalSliderCell: NSSliderCell {
    
    var barRadius: CGFloat {return 1}
    var barGradient: NSGradient {return Colors.sliderBarGradient}
    var barInsetX: CGFloat {return 0}
    var barInsetY: CGFloat {return 0}
    
    var knobWidth: CGFloat {return 10}
    var knobHeightOutsideBar: CGFloat {return 2}
    var knobRadius: CGFloat {return 1}
    var knobColor: NSColor {return Colors.sliderKnobColor}
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let drawPath = NSBezierPath.init(roundedRect: aRect, xRadius: barRadius, yRadius: barRadius)
        barGradient.draw(in: drawPath, angle: -UIConstants.verticalGradientDegrees)
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

class VolumeSliderCell: HorizontalSliderCell {
    
    override var knobWidth: CGFloat {return 7}
    override var knobRadius: CGFloat {return 0.5}
    override var knobHeightOutsideBar: CGFloat {return 1}
}

class SeekSliderCell: HorizontalSliderCell {
    
    override var barRadius: CGFloat {return 0.5}
    override var barInsetY: CGFloat {return 0.5}
    override var knobRadius: CGFloat {return 0.5}
}

// For sliders on the Preferences panel
class PreferencesSliderCell: HorizontalSliderCell {
    
    override var barRadius: CGFloat {return 1.5}
    override var barInsetY: CGFloat {return -1}
}

class EffectsSliderCell: HorizontalSliderCell {
    
    override var barRadius: CGFloat {return 1.5}
    override var barInsetY: CGFloat {return -1}
    override var knobRadius: CGFloat {return 1}
    override var knobHeightOutsideBar: CGFloat {return 1}
}
