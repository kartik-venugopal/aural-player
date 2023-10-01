//
//  HorizontalSliderCell.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
    Customizes the look and feel of all non-ticked horizontal sliders
*/

import Cocoa

// Base class for all horizontal slider cells
class HorizontalSliderCell: NSSliderCell {
    
    // TODO: Apply logic from SeekSliderCell.drawKnob and knobRect here in this class (so that all sliders can benefit from it)
    
    var barRadius: CGFloat {1}
    
    var backgroundGradient: NSGradient {Colors.Player.sliderBackgroundGradient}
    var foregroundGradient: NSGradient {Colors.Player.sliderForegroundGradient}
    var gradientDegrees: CGFloat {.horizontalGradientDegrees}
    
    var barInsetX: CGFloat {0}
    var barInsetY: CGFloat {0}
    
    var knobWidth: CGFloat {10}
    var knobHeightOutsideBar: CGFloat {2}
    var knobRadius: CGFloat {1}
    var knobColor: NSColor {Colors.Player.sliderKnobColor}
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let knobFrame = knobRect(flipped: false)
        let halfKnobWidth = knobFrame.width / 2
        
        let leftRect = NSRect(x: aRect.minX, y: aRect.minY, width: max(halfKnobWidth, knobFrame.minX + halfKnobWidth), height: aRect.height)
        NSBezierPath.fillRoundedRect(leftRect, radius: barRadius, withGradient: foregroundGradient, angle: gradientDegrees)
        
        let rightRect = NSRect(x: knobFrame.maxX - halfKnobWidth, y: aRect.minY, width: aRect.width - (knobFrame.maxX - halfKnobWidth), height: aRect.height)
        NSBezierPath.fillRoundedRect(rightRect, radius: barRadius, withGradient: backgroundGradient, angle: gradientDegrees)
    }
    
    override internal func drawKnob(_ knobRect: NSRect) {
        
        let rectWidth = knobRect.width
        let bar = barRect(flipped: true)
        let xCenter = knobRect.minX + (rectWidth / 2)
        
        let knobHeight: CGFloat = bar.height + knobHeightOutsideBar
        let knobMinX = xCenter - (knobWidth / 2)
        let rect = NSRect(x: knobMinX, y: bar.minY - ((knobHeight - bar.height) / 2), width: knobWidth, height: knobHeight)
        
        NSBezierPath.fillRoundedRect(rect, radius: knobRadius, withColor: knobColor)
    }
    
    override func barRect(flipped: Bool) -> NSRect {
        super.barRect(flipped: flipped).insetBy(dx: barInsetX, dy: barInsetY)
    }
}
