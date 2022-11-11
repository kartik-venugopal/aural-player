//
//  ControlBarSeekSliderCell.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class ControlBarSeekSliderCell: SeekSliderCell {
    
    override var barInsetY: CGFloat {System.isBigSur ? -0.5 : 0}
    override var barRadius: CGFloat {1}
    
    private let loopMarkerWidth: CGFloat = 8
    private lazy var halfLoopMarkerWidth: CGFloat = loopMarkerWidth / 2
    
    // Interpret start value as percentage of slider width, not as an X value.
    override func markLoopStart(_ start: CGFloat) {
        self.loop = PlaybackLoopRange(start: start, end: nil)
    }
    
    // Marks the rendering end point for a segment playback loop. The end argument is the X co-ordinate of the center of the knob frame at the loop end point
    override func markLoopEnd(_ end: CGFloat) {
        self.loop?.end = end
    }
    
    // Don't draw the knob
    override func drawKnob(_ knobRect: NSRect) {}
    
    // Limit the tracking rect so that events don't conflict with clicks outside the (visible) slider.
    override func trackMouse(with event: NSEvent, in cellFrame: NSRect, of controlView: NSView, untilMouseUp flag: Bool) -> Bool {
        
        if event.locationInWindow.y <= 6 {
            return super.trackMouse(with: event, in: cellFrame, of: controlView, untilMouseUp: flag)
        }
        
        return false
    }
    
    override func barRect(flipped: Bool) -> NSRect {
        
        let superRect = super.barRect(flipped: false)
        let isBigSur: Bool = System.isBigSur
        
        return NSMakeRect(superRect.minX, isBigSur ? 6 : 2, superRect.width, superRect.height)
    }
    
    override func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let scaledValue = CGFloat(doubleValue / 100)
        
        var leftRect: NSRect = .zero
        
        if scaledValue > 0 {
            
            leftRect = NSRect(x: aRect.minX, y: aRect.minY,
                                  width: max(1, scaledValue * aRect.width), height: aRect.height)
            
            NSBezierPath.fillRoundedRect(leftRect, radius: barRadius, withGradient: foregroundGradient, angle: gradientDegrees)
        }
        
        if scaledValue < 100 {
            
            let rightRect = NSRect(x: leftRect.maxX, y: aRect.minY,
                                   width: max(1, aRect.width - leftRect.width), height: aRect.height)
            
            NSBezierPath.fillRoundedRect(rightRect, radius: barRadius, withGradient: backgroundGradient, angle: gradientDegrees)
        }
        
        // Render segment playback loop, if one is defined
        if let loop = self.loop {
            
            // Current seek position
            let curSeekPos = (aRect.minX + halfLoopMarkerWidth + (scaledValue * (aRect.width - loopMarkerWidth)))
            
            // Start and end points for the loop
            let startX = aRect.minX + (loop.start * aRect.width / 100)
            let endX: CGFloat
            
            if let loopEndPerc = loop.end {
                endX = aRect.minX + (loopEndPerc * aRect.width / 100)
            } else {
                endX = curSeekPos + halfLoopMarkerWidth
            }
            
            // Loop bar
            let loopRect = NSRect(x: startX, y: aRect.minY, width: max(1, endX - startX), height: aRect.height)
            NSBezierPath.fillRoundedRect(loopRect, radius: barRadius, withColor: loopColor)
            
            // Current position marker
            let markerStartX = max(aRect.minX, curSeekPos - halfLoopMarkerWidth)
            let markerRect = NSMakeRect(markerStartX, aRect.minY, loopMarkerWidth, aRect.height)
            NSBezierPath.fillRoundedRect(markerRect, radius: knobRadius, withGradient: foregroundGradient, angle: gradientDegrees)
        }
    }
}
