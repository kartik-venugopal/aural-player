//
//  SeekSliderCell.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

// Defines the range (start and end points) used to render a track segment playback loop
class PlaybackLoopRange {
    
    let startPerc: CGFloat
    var endPerc: CGFloat?
    
    var isComplete: Bool {endPerc != nil}
    
    init(startPerc: CGFloat) {
        
        self.startPerc = startPerc
        self.endPerc = nil
    }
}

// Cell for seek position slider
class SeekSliderCell: HorizontalSliderCell {
    
    override var barHeight: CGFloat {2}
    
    private lazy var loopMarkerHeight: CGFloat = barHeight + (2 * (knobHeightOutsideBar))
    
    var loop: PlaybackLoopRange?
    
    // Returns the center of the current knob frame
    var knobCenter: CGFloat {
        knobRect(flipped: false).centerX
    }
    
    // Marks the rendering start point for a segment playback loop. The start argument is the X co-ordinate of the center of the knob frame at the loop start point
    func markLoopStart(startPerc: CGFloat) {
        self.loop = PlaybackLoopRange(startPerc: startPerc)
    }
    
    // Marks the rendering end point for a segment playback loop. The end argument is the X co-ordinate of the center of the knob frame at the loop end point
    func markLoopEnd(endPerc: CGFloat) {
        self.loop?.endPerc = endPerc
    }
    
    // Invalidates the track segment playback loop
    func removeLoop() {
        self.loop = nil
    }
    
    override func knobRect(flipped: Bool) -> NSRect {
        .zero
    }
    
    override func progressRect(forBarRect barRect: NSRect, andKnobRect knobRect: NSRect) -> NSRect {
        
        var progress = (doubleValue - minValue) / (maxValue - minValue)
        
        if let loop = self.loop {
            
            progress -= (loop.startPerc / 100)
            
            let barStartX = barRect.minX + (loop.startPerc / 100) * barRect.width
            return NSRect(x: barStartX, y: barRect.minY, width: CGFloat(progress) * barRect.width, height: barRect.height)
            
        } else {
            return NSRect(x: barRect.minX, y: barRect.minY, width: CGFloat(progress) * barRect.width, height: barRect.height)
        }
    }
    
    // Don't draw the knob.
    override func drawKnob() {}
    
    override func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        super.drawBar(inside: aRect, flipped: flipped)
        
        guard let loop = self.loop else {
            return
        }
        
        // ------- MARK: Loop Markers -------------------------------------------------
        
        func drawLoopMarkerRect(forPerc perc: CGFloat) {
            
            let centerX = aRect.minX + (perc * aRect.width / 100)
            let minX = max(aRect.minX, centerX - halfKnobWidth)
            let markerRect = NSRect(x: minX, y: aRect.minY - knobHeightOutsideBar, width: knobWidth, height: loopMarkerHeight)
            
            NSBezierPath.fillRoundedRect(markerRect, radius: knobRadius, withColor: controlStateColor)
            NSBezierPath.strokeRoundedRect(markerRect, radius: knobRadius, withColor: systemColorScheme.backgroundColor, lineWidth: 2)
        }
        
        // Render segment playback loop, if one is defined
        drawLoopMarkerRect(forPerc: loop.startPerc)
        
        if let loopEndPerc = loop.endPerc {
            drawLoopMarkerRect(forPerc: loopEndPerc)
        }
    }
}
