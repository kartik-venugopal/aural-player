//
//  AuralSliderCell.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
    Customizes the look and feel of all non-ticked horizontal sliders
*/

import Cocoa

// Base class for all horizontal slider cells
class AuralSliderCell: NSSliderCell {
    
    lazy var valueRange: Double = maxValue - minValue
    
    var knobPhysicalTravelRange: CGFloat {0}
    
    // ----------------------------------------------------
    
    // MARK: Bar

    var barRadius: CGFloat {1}
    
    // ----------------------------------------------------
    
    // MARK: Knob
    
    var knobWidth: CGFloat {12}
    var knobRadius: CGFloat {1.5}
    
    // ----------------------------------------------------
    
    // MARK: Ticks
    
    var tickWidth: CGFloat {2}
    var tickColor: NSColor {.sliderNotchColor}
    
    // ----------------------------------------------------
    
    // MARK: Colors
    
    var backgroundColor: NSColor {systemColorScheme.inactiveControlColor}
    
    var controlStateColor: NSColor {
        systemColorScheme.activeControlColor
    }
    
    // ----------------------------------------------------
    
    // MARK: Init
    
    var originalKnobRect: NSRect {
        super.knobRect(flipped: false)
    }
    
    var originalBarRect: NSRect {
        super.barRect(flipped: false)
    }
    
    var progress: CGFloat {CGFloat((doubleValue - minValue) / valueRange)}
    
    override func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        drawBackground(inRect: aRect)
        
        let progressRect = progressRect(forBarRect: aRect, andKnobRect: knobRect(flipped: false))
        drawProgress(inRect: progressRect)
        
        drawTicks(aRect)
    }
    
    /// OVERRIDE THIS !
    func progressRect(forBarRect barRect: NSRect, andKnobRect knobRect: NSRect) -> NSRect {
        .zero
    }
    
    func drawProgress(inRect rect: NSRect) {
        
        if rect.width > 0 {
            NSBezierPath.fillRoundedRect(rect, radius: barRadius, withColor: controlStateColor)
        }
    }
    
    func drawBackground(inRect rect: NSRect) {

        let startPoint = NSMakePoint(rect.minX, rect.centerY)
        let endPoint = NSMakePoint(rect.maxX, rect.centerY)
        GraphicsUtils.drawLine(systemColorScheme.inactiveControlColor, pt1: startPoint, pt2: endPoint, width: 1)
    }
    
    func drawTicks(_ aRect: NSRect) {
        
        // Draw ticks (as notches, within the bar)
        switch numberOfTickMarks {
            
        case 3..<Int.max:
            
            for i in 1...numberOfTickMarks - 2 {
                drawTick(i, aRect)
            }
            
        case 1:
            drawTick(0, aRect)
            
        default:
            return
        }
    }
    
    func drawTick(_ index: Int, _ barRect: NSRect) {}
}
