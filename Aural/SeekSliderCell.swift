/*
 Customizes the look and feel of all non-ticked horizontal sliders
 */

import Cocoa

fileprivate let seekBarPlainGradient: NSGradient = {
    
    let backgroundStart = NSColor(white: 0.4, alpha: 1.0)
    let backgroundEnd =  NSColor(white: 0.2, alpha: 1.0)
    
    let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
    
    return barBackgroundGradient!
}()

fileprivate let seekBarColoredGradient: NSGradient = {
    
    let backgroundStart = NSColor(white: 0.6, alpha: 1.0)
    let backgroundEnd =  NSColor(white: 0.4, alpha: 1.0)
    
//    let backgroundStart = NSColor(calibratedRed: 0.65, green: 0.1, blue: 0.2, alpha: 1)
//    let backgroundEnd =  NSColor(calibratedRed: 0.35, green: 0.1, blue: 0.1, alpha: 1)
    
    let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
    
    return barBackgroundGradient!
}()

// Cell for seek position slider
class NewSeekSliderCell: HorizontalSliderCell {
    
    override var barRadius: CGFloat {return 0.5}
    override var barInsetY: CGFloat {return 0}
    
    override var knobRadius: CGFloat {return 1}
    override var knobColor: NSColor {return NSColor(white: 0.5, alpha: 1.0)}
    override var knobWidth: CGFloat {return 8}
    override var knobHeightOutsideBar: CGFloat {return 1}
    
    override var barPlainGradient: NSGradient {return seekBarPlainGradient}
    override var barColoredGradient: NSGradient {return seekBarColoredGradient}
    
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
    
    override func barRect(flipped: Bool) -> NSRect {
        
        var superRect = super.barRect(flipped: flipped).insetBy(dx: barInsetX, dy: barInsetY)
        let oldOrigin = superRect.origin
        superRect.origin = NSPoint(x: 0, y: oldOrigin.y)
        
        return superRect
    }
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let knobFrame = knobRect(flipped: false)
        let halfKnobWidth = knobFrame.width / 2
        
        let leftRect = NSRect(x: aRect.minX, y: aRect.minY, width: max(halfKnobWidth, knobFrame.minX + halfKnobWidth), height: aRect.height)
        
        var drawPath = NSBezierPath.init(roundedRect: leftRect, xRadius: barRadius, yRadius: barRadius)
        barColoredGradient.draw(in: drawPath, angle: gradientDegrees)
        
        let rightRect = NSRect(x: knobFrame.maxX - halfKnobWidth, y: aRect.minY, width: aRect.width - (knobFrame.maxX - halfKnobWidth), height: aRect.height)
        
        drawPath = NSBezierPath.init(roundedRect: rightRect, xRadius: barRadius, yRadius: barRadius)
        barPlainGradient.draw(in: drawPath, angle: gradientDegrees)
        
        // Render segment playback loop, if one is defined
        if let loop = self.loop {
            
            // Start and end points for the loop
            let startX = loop.start
            let endX = loop.end ?? max(startX + 1, knobFrame.minX + halfKnobWidth)
            
            // Loop bar
            let loopRect = NSRect(x: startX, y: aRect.minY, width: (endX - startX + 1), height: aRect.height)
            var drawPath = NSBezierPath.init(roundedRect: loopRect, xRadius: barRadius, yRadius: barRadius)
            Colors.playbackLoopGradient.draw(in: drawPath, angle: UIConstants.verticalGradientDegrees)
            
            let markerMinY = knobFrame.minY
            let markerHeight: CGFloat = aRect.height + knobHeightOutsideBar * 2
            let markerRadius: CGFloat = 0
            
            // Loop start marker
            let loopStartMarker = NSRect(x: startX - (knobWidth / 2), y: markerMinY, width: knobWidth, height: markerHeight)
            drawPath = NSBezierPath.init(roundedRect: loopStartMarker, xRadius: markerRadius, yRadius: markerRadius)
            Colors.playbackLoopGradient.draw(in: drawPath, angle: UIConstants.verticalGradientDegrees)
            
            // Loop end marker
            if (loop.end != nil) {
                
                let loopEndMarker = NSRect(x: endX - (knobWidth / 2), y: markerMinY, width: knobWidth, height: markerHeight)
                drawPath = NSBezierPath.init(roundedRect: loopEndMarker, xRadius: markerRadius, yRadius: markerRadius)
                Colors.playbackLoopGradient.draw(in: drawPath, angle: UIConstants.verticalGradientDegrees)
            }
        }
    }
    
    override func knobRect(flipped: Bool) -> NSRect {
        
        let bar = barRect(flipped: flipped)
        let val = CGFloat(self.doubleValue)
        
        let startX = val * bar.width / 100
        let xOffset = -(val * knobWidth / 100)
        
        let newX = startX + xOffset
        let newY = bar.minY - knobHeightOutsideBar
        
        return NSRect(x: newX, y: newY, width: knobWidth, height: knobHeightOutsideBar * 2 + bar.height)
    }
    
    override internal func drawKnob(_ knobRect: NSRect) {
        
        let bar = barRect(flipped: true)

        let knobHeight: CGFloat = bar.height + knobHeightOutsideBar * 2
        let knobMinX = knobRect.minX
        let rect = NSRect(x: knobMinX, y: bar.minY - ((knobHeight - bar.height) / 2), width: knobWidth, height: knobHeight)

        let knobPath = NSBezierPath(roundedRect: rect, xRadius: knobRadius, yRadius: knobRadius)
        knobColor.setFill()
        knobPath.fill()
        
        //        NSColor.white.setStroke()
        //        knobPath.lineWidth = 0.5
        //        knobPath.stroke()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
