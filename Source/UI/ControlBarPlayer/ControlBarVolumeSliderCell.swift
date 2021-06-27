//
//  ControlBarVolumeSliderCell.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class ControlBarVolumeSliderCell: VolumeSliderCell {
    
    // Don't draw the knob.
    override internal func drawKnob(_ knobRect: NSRect) {}
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let scaledValue = CGFloat(floatValue / 100)
        
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
    }
}
