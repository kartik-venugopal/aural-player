//
//  SeekSliderCell.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

// Defines the range (start and end points) used to render a track segment playback loop
struct PlaybackLoopRange {
    
    // Both are X co-ordinates
    
    var start: CGFloat
    var end: CGFloat?
}

// Cell for seek position slider
class SeekSliderCell: HorizontalSliderCell {
    
    override var barInsetY: CGFloat {SystemUtils.isBigSur ? 0 : 0.5}
    
    override var knobRadius: CGFloat {1}
    override var knobWidth: CGFloat {10}
    override var knobHeightOutsideBar: CGFloat {2}
    
    var loopColor: NSColor {Colors.Player.seekBarLoopColor}
    
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
    
    func drawLeftRect(inRect rect: NSRect, knobFrame: NSRect) {
        
        let halfKnobWidth = knobFrame.width / 2
        
        let leftRect = NSRect(x: rect.minX, y: rect.minY, width: max(halfKnobWidth, knobFrame.minX + halfKnobWidth), height: rect.height)
        let path = NSBezierPath(roundedRect: leftRect, xRadius: barRadius, yRadius: barRadius)
        foregroundGradient.draw(in: path, angle: gradientDegrees)
    }
    
    func drawRightRect(inRect rect: NSRect, knobFrame: NSRect) {
        
        let halfKnobWidth = knobFrame.width / 2
        
        let rightRect = NSRect(x: knobFrame.maxX - halfKnobWidth, y: rect.minY, width: rect.width - (knobFrame.maxX - halfKnobWidth), height: rect.height)
        let path = NSBezierPath(roundedRect: rightRect, xRadius: barRadius, yRadius: barRadius)
        backgroundGradient.draw(in: path, angle: gradientDegrees)
    }
    
    override func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let knobFrame = knobRect(flipped: false)
        
        drawLeftRect(inRect: aRect, knobFrame: knobFrame)
        drawRightRect(inRect: aRect, knobFrame: knobFrame)
        
        // Render segment playback loop, if one is defined
        if let loop = self.loop {
            
            let halfKnobWidth = knobFrame.width / 2

            // Start and end points for the loop
            let startX = loop.start
            let endX = loop.end ?? max(startX + 1, knobFrame.minX + halfKnobWidth)
            
            // Loop bar
            let loopRect = NSRect(x: startX, y: aRect.minY, width: (endX - startX + 1), height: aRect.height)
            var drawPath = NSBezierPath.init(roundedRect: loopRect, xRadius: barRadius, yRadius: barRadius)
            loopColor.setFill()
            drawPath.fill()
            
            let markerMinY = knobFrame.minY + knobHeightOutsideBar / 2
            let markerHeight: CGFloat = aRect.height + knobHeightOutsideBar
            
            // Loop start marker
            let loopStartMarker = NSRect(x: startX - (knobWidth / 2), y: markerMinY, width: knobWidth, height: markerHeight)
            drawPath = NSBezierPath.init(roundedRect: loopStartMarker, xRadius: knobRadius, yRadius: knobRadius)
            loopColor.setFill()
            drawPath.fill()
            
            // Loop end marker
            if loop.end != nil {
            
                let loopEndMarker = NSRect(x: endX - (knobWidth / 2), y: markerMinY, width: knobWidth, height: markerHeight)
                drawPath = NSBezierPath.init(roundedRect: loopEndMarker, xRadius: knobRadius, yRadius: knobRadius)
                loopColor.setFill()
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
    
    override func drawKnob(_ knobRect: NSRect) {
        
        let bar = barRect(flipped: true)
        
        let knobHeight: CGFloat = bar.height + knobHeightOutsideBar
        let knobMinX = knobRect.minX
        let rect = NSRect(x: knobMinX, y: bar.minY - ((knobHeight - bar.height) / 2), width: knobWidth, height: knobHeight)
        
        let knobPath = NSBezierPath(roundedRect: rect, xRadius: knobRadius, yRadius: knobRadius)
        knobColor.setFill()
        knobPath.fill()
    }
}
