//
//  ControlBarSeekSliderCell.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class ControlBarSeekSliderCell: SeekSliderCell {
    
    override var barInsetY: CGFloat {0}
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
    
    override func barRect(flipped: Bool) -> NSRect {
        
        let superRect = super.barRect(flipped: flipped)
        return NSMakeRect(superRect.minX, 5, superRect.width, superRect.height)
    }
    
    override func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let scaledValue = CGFloat(doubleValue / 100)
        
        var leftRect: NSRect = .zero
        
        if scaledValue > 0 {
            
            leftRect = NSRect(x: aRect.minX, y: aRect.minY,
                                  width: max(1, scaledValue * aRect.width), height: aRect.height)
            
            let leftRectPath = NSBezierPath.init(roundedRect: leftRect, xRadius: barRadius, yRadius: barRadius)
            foregroundGradient.draw(in: leftRectPath, angle: gradientDegrees)
        }
        
        if scaledValue < 100 {
            
            let rightRect = NSRect(x: leftRect.maxX, y: aRect.minY,
                                   width: max(1, aRect.width - leftRect.width), height: aRect.height)
            
            let rightRectPath = NSBezierPath.init(roundedRect: rightRect, xRadius: barRadius, yRadius: barRadius)
            backgroundGradient.draw(in: rightRectPath, angle: gradientDegrees)
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
            var drawPath = NSBezierPath.init(roundedRect: loopRect, xRadius: barRadius, yRadius: barRadius)
            loopColor.setFill()
            drawPath.fill()
            
            // Current position marker
            let markerStartX = max(aRect.minX, curSeekPos - halfLoopMarkerWidth)
            let markerRect = NSMakeRect(markerStartX, aRect.minY, loopMarkerWidth, aRect.height)
            drawPath = NSBezierPath(rect: markerRect)
            foregroundGradient.draw(in: drawPath, angle: gradientDegrees)
        }
    }
}
