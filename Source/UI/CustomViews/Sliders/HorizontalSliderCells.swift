/*
    Customizes the look and feel of all non-ticked horizontal sliders
*/

import Cocoa

// Base class for all horizontal slider cells
class HorizontalSliderCell: NSSliderCell {
    
    // TODO: Apply logic from SeekSliderCell.drawKnob and knobRect here in this class (so that all sliders can benefit from it)
    
    var barRadius: CGFloat {return 1}
    
    var backgroundGradient: NSGradient {return Colors.Player.sliderBackgroundGradient}
    var foregroundGradient: NSGradient {return Colors.Player.sliderForegroundGradient}
    var gradientDegrees: CGFloat {return UIConstants.horizontalGradientDegrees}
    
    var barInsetX: CGFloat {return 0}
    var barInsetY: CGFloat {return 0}
    
    var knobWidth: CGFloat {return 10}
    var knobHeightOutsideBar: CGFloat {return 2}
    var knobRadius: CGFloat {return 1}
    var knobColor: NSColor {return Colors.Player.sliderKnobColor}
    
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

// Cell for volume slider
class VolumeSliderCell: HorizontalSliderCell {
    
    override var barRadius: CGFloat {return 1}
    override var barInsetY: CGFloat {return SystemUtils.isBigSur ? 0 : 0.5}
    
    override var knobWidth: CGFloat {return 6}
    override var knobRadius: CGFloat {return 0.5}
    override var knobHeightOutsideBar: CGFloat {return 1.5}
    
    override func knobRect(flipped: Bool) -> NSRect {
        
        let bar = barRect(flipped: flipped)
        let val = CGFloat(self.doubleValue)
        
        let startX = bar.minX + (val * bar.width / 100)
        let xOffset = -(val * knobWidth / 100)
        
        let newX = startX + xOffset
        let newY = bar.minY - knobHeightOutsideBar
        
        return NSRect(x: newX, y: newY, width: knobWidth, height: knobHeightOutsideBar * 2 + bar.height)
    }
}

// Defines the range (start and end points) used to render a track segment playback loop
struct PlaybackLoopRange {
    
    // Both are X co-ordinates
    
    var start: CGFloat
    var end: CGFloat?
}

// Cell for seek position slider
class SeekSliderCell: HorizontalSliderCell {
    
    override var barRadius: CGFloat {return 1}
    override var barInsetY: CGFloat {return SystemUtils.isBigSur ? 0 : 0.5}
    
    override var knobRadius: CGFloat {return 1}
    override var knobWidth: CGFloat {return 10}
    override var knobHeightOutsideBar: CGFloat {return 2}
    
    var loop: PlaybackLoopRange?
    
    // Returns the center of the current knob frame
    var knobCenter: CGFloat {
        return knobRect(flipped: false).centerX
    }
    
    // Marks the rendering start point for a segment playback loop. The start argument is the X co-ordinate of the center of the knob frame at the loop start point
    func markLoopStart(_ start: CGFloat) {
        self.loop = PlaybackLoopRange(start: start, end: nil)
    }
    
    // Marks the rendering end point for a segment playback loop. The end argument is the X co-ordinate of the center of the knob frame at the loop end point
    func markLoopEnd(_ end: CGFloat) {
        self.loop?.end = end
    }
    
    // Invalidates the track segment playback loop
    func removeLoop() {
        self.loop = nil
    }
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let knobFrame = knobRect(flipped: false)
        let halfKnobWidth = knobFrame.width / 2
        
        let leftRect = NSRect(x: aRect.minX, y: aRect.minY, width: max(halfKnobWidth, knobFrame.minX + halfKnobWidth), height: aRect.height)
        foregroundGradient.draw(in: leftRect, angle: gradientDegrees)
        
        let rightRect = NSRect(x: knobFrame.maxX - halfKnobWidth, y: aRect.minY, width: aRect.width - (knobFrame.maxX - halfKnobWidth), height: aRect.height)
        backgroundGradient.draw(in: rightRect, angle: gradientDegrees)
        
        // Render segment playback loop, if one is defined
        if let loop = self.loop {

            // Start and end points for the loop
            let startX = loop.start
            let endX = loop.end ?? max(startX + 1, knobFrame.minX + halfKnobWidth)
            
            // Loop bar
            let loopRect = NSRect(x: startX, y: aRect.minY, width: (endX - startX + 1), height: aRect.height)
            var drawPath = NSBezierPath.init(roundedRect: loopRect, xRadius: barRadius, yRadius: barRadius)
            Colors.Player.seekBarLoopColor.setFill()
            drawPath.fill()
            
            let markerMinY = knobFrame.minY + knobHeightOutsideBar / 2
            let markerHeight: CGFloat = aRect.height + knobHeightOutsideBar
            
            // Loop start marker
            let loopStartMarker = NSRect(x: startX - (knobWidth / 2), y: markerMinY, width: knobWidth, height: markerHeight)
            drawPath = NSBezierPath.init(roundedRect: loopStartMarker, xRadius: knobRadius, yRadius: knobRadius)
            Colors.Player.seekBarLoopColor.setFill()
            drawPath.fill()
            
            // Loop end marker
            if (loop.end != nil) {
            
                let loopEndMarker = NSRect(x: endX - (knobWidth / 2), y: markerMinY, width: knobWidth, height: markerHeight)
                drawPath = NSBezierPath.init(roundedRect: loopEndMarker, xRadius: knobRadius, yRadius: knobRadius)
                Colors.Player.seekBarLoopColor.setFill()
                drawPath.fill()
            }
        }
    }
    
    override func knobRect(flipped: Bool) -> NSRect {
        
        let bar = barRect(flipped: flipped)
        let val = CGFloat(self.doubleValue)
        
        let startX = bar.minX + (val * bar.width / 100)
        let xOffset = -(val * knobWidth / 100)
        
        let newX = startX + xOffset
        let newY = bar.minY - knobHeightOutsideBar
        
        return NSRect(x: newX, y: newY, width: knobWidth, height: knobHeightOutsideBar * 2 + bar.height)
    }
    
    override internal func drawKnob(_ knobRect: NSRect) {
        
        let bar = barRect(flipped: true)
        
        let knobHeight: CGFloat = bar.height + knobHeightOutsideBar
        let knobMinX = knobRect.minX
        let rect = NSRect(x: knobMinX, y: bar.minY - ((knobHeight - bar.height) / 2), width: knobWidth, height: knobHeight)
        
        let knobPath = NSBezierPath(roundedRect: rect, xRadius: knobRadius, yRadius: knobRadius)
        knobColor.setFill()
        knobPath.fill()
    }
}

// Cell for sliders on the Preferences panel
class PreferencesSliderCell: HorizontalSliderCell {
    
    override var barRadius: CGFloat {return 1.5}
    override var barInsetY: CGFloat {return 0.5}
    
    override var backgroundGradient: NSGradient {return Colors.Effects.defaultSliderBackgroundGradient}
    override var foregroundGradient: NSGradient {return Colors.Effects.defaultSliderBackgroundGradient}
    
    override var knobColor: NSColor {return Colors.Constants.white80Percent}
}

extension NSRect {
    
    var centerX: CGFloat {
        return self.minX + (self.width / 2)
    }
    
    var centerY: CGFloat {
        return self.minY + (self.height / 2)
    }
}
