//
//  TickedSliderCell.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
    Customizes the look and feel of all ticked horizontal sliders
 */

import Cocoa

// Base class for all ticked horizontal slider cells
class TickedSliderCell: HorizontalSliderCell {
    
    var tickVerticalSpacing: CGFloat {1}
    var tickWidth: CGFloat {2}
    var tickColor: NSColor {.sliderNotchColor}
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        super.drawBar(inside: aRect, flipped: flipped)
        drawTicks(aRect)
    }
    
    internal func drawTicks(_ aRect: NSRect) {
        
        // Draw ticks (as notches, within the bar)
        let ticksCount = self.numberOfTickMarks
        
        if (ticksCount > 2) {
            
            for i in 1...ticksCount - 2 {
                drawTick(i, aRect)
            }
            
        } else if (ticksCount == 1) {
            drawTick(0, aRect)
        }
    }
    
    // Draws a single tick within a bar
    internal func drawTick(_ index: Int, _ barRect: NSRect) {
        
        let tickMinY = barRect.minY + tickVerticalSpacing
        let tickMaxY = barRect.maxY - tickVerticalSpacing
        
        let tickRect = rectOfTickMark(at: index)
        let x = (tickRect.minX + tickRect.maxX) / 2
        
        GraphicsUtils.drawLine(tickColor, pt1: NSMakePoint(x, tickMinY), pt2: NSMakePoint(x, tickMaxY), width: tickWidth)
    }
    
    override func drawTickMarks() {
        // Do nothing (ticks are drawn in drawBar)
    }
}

