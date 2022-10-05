//
//  PanSliderCell.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

// Cell for pan slider
class PanSliderCell: TickedSliderCell {
    
    override var barRadius: CGFloat {1}
    override var barInsetY: CGFloat {System.isBigSur ? 0 : 0.5}
    
    override var knobWidth: CGFloat {6}
    override var knobRadius: CGFloat {0.5}
    override var knobHeightOutsideBar: CGFloat {1.5}
    
    // Draw entire bar with single gradient
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        NSBezierPath.fillRoundedRect(aRect.leftHalf, radius: barRadius, withGradient: backgroundGradient.reversed(), angle: .horizontalGradientDegrees)
        NSBezierPath.fillRoundedRect(aRect.rightHalf, radius: barRadius, withGradient: backgroundGradient, angle: .horizontalGradientDegrees)
        
        drawTicks(aRect)
        
        // Draw rect between knob and center, to show panning
        let knobCenter = knobRect(flipped: false).centerX
        let barCenter = aRect.centerX
        let panRectX = min(knobCenter, barCenter)
        let panRectWidth = abs(knobCenter - barCenter)
        
        if panRectWidth > 0 {
            
            let panRect = NSRect(x: panRectX, y: aRect.minY, width: panRectWidth, height: aRect.height)
            let gradient = doubleValue > 0 ? foregroundGradient : foregroundGradient.reversed()
            
            NSBezierPath.fillRoundedRect(panRect, radius: barRadius, withGradient: gradient, angle: -.horizontalGradientDegrees)
        }
    }
    
    override func knobRect(flipped: Bool) -> NSRect {
        
        let bar = barRect(flipped: flipped)
        let val = CGFloat(self.doubleValue)
        let perc: CGFloat = 50 + (val / 2)
        
        let startX = bar.minX + perc * bar.width / 100
        let xOffset = -(perc * knobWidth / 100)
        
        let newX = startX + xOffset
        let newY = bar.minY - knobHeightOutsideBar
        
        return NSRect(x: newX, y: newY, width: knobWidth, height: knobHeightOutsideBar * 2 + bar.height)
    }
}
