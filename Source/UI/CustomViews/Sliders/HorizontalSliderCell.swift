//
//  HorizontalSliderCell.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class HorizontalSliderCell: AuralSliderCell {
    
    var barHeight: CGFloat {3}
    
    var knobHeightOutsideBar: CGFloat {2.5}
    
    lazy var halfKnobWidth = knobWidth / 2
    
    var tickVerticalSpacing: CGFloat {1}
    
    override func progressRect(forBarRect barRect: NSRect, andKnobRect knobRect: NSRect) -> NSRect {
        NSRect(x: barRect.minX, y: barRect.minY, width: max(halfKnobWidth, knobRect.minX + halfKnobWidth), height: barRect.height)
    }
    
    override func barRect(flipped: Bool) -> NSRect {
        
        let superRect = originalBarRect
        
        let xDiff = -superRect.minX
        let yDiff = (superRect.height - barHeight) / 2
        
        return superRect.insetBy(dx: xDiff, dy: yDiff)
    }
    
    override func knobRect(flipped: Bool) -> NSRect {
        
        let bar = barRect(flipped: false)
        let val = CGFloat(doubleValue - minValue)
        
        let startX = bar.minX + (val * bar.width / valueRange)
        let xOffset = -(val * knobWidth / valueRange)
        
        let newX = startX + xOffset
        let newY = bar.minY - knobHeightOutsideBar
        
        return NSRect(x: newX, y: newY,
                      width: knobWidth,
                      height: knobHeightOutsideBar * 2 + bar.height)
    }
    
    // Draws a single tick within a bar
    override func drawTick(_ index: Int, _ barRect: NSRect) {
        
        let tickMinY = barRect.minY + tickVerticalSpacing
        let tickMaxY = barRect.maxY - tickVerticalSpacing
        
        let tickRect = rectOfTickMark(at: index)
        let x = (tickRect.minX + tickRect.maxX) / 2
        
        GraphicsUtils.drawLine(tickColor, pt1: NSMakePoint(x, tickMinY), pt2: NSMakePoint(x, tickMaxY), width: tickWidth)
    }
    
    override func drawTickMarks() {
        // Do nothing (ticks are drawn in drawBar)
    }
    
    override func drawKnob(_ knobRect: NSRect) {

        let bar = barRect(flipped: false)
        let knobHeight: CGFloat = bar.height + knobHeightOutsideBar
        let knobMinX = knobRect.minX
        
        let knobRect = NSRect(x: knobMinX, y: bar.minY - ((knobHeight - bar.height) / 2), width: knobWidth, height: knobHeight)

        NSBezierPath.fillRoundedRect(knobRect, radius: knobRadius, withColor: controlStateColor)
        NSBezierPath.strokeRoundedRect(knobRect, radius: knobRadius, withColor: systemColorScheme.backgroundColor, lineWidth: 2)
    }
}
