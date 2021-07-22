//
//  EQSliderCell.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Customizes the look and feel of the parametric EQ sliders
 */
class EQSliderCell: NSSliderCell {
    
    private let barRadius: CGFloat = 0.75
    private let barInsetX: CGFloat = 0
    private let barInsetY: CGFloat = 0
    
    private let tickInset: CGFloat = 1.5
    private let tickWidth: CGFloat = 2
    
    private let knobHeight: CGFloat = 10
    private let knobRadius: CGFloat = 1
    private let knobWidthOutsideBar: CGFloat = 1.5
    
    var unitState: EffectsUnitState = .bypassed
    
    var foregroundGradient: NSGradient {
    
        switch unitState {
        
        case .active:   return Colors.Effects.activeSliderGradient
        
        case .bypassed: return Colors.Effects.bypassedSliderGradient
        
        case .suppressed:   return Colors.Effects.suppressedSliderGradient
        
        }
    }
    
    var backgroundGradient: NSGradient {
        Colors.Effects.sliderBackgroundGradient
    }
    
    var knobColor: NSColor {
        Colors.Effects.sliderKnobColorForState(unitState)
    }
    
    // Force knobRect and barRect to NOT be flipped
    
    override func knobRect(flipped: Bool) -> NSRect {
        super.knobRect(flipped: SystemUtils.isBigSur)
    }
    
    override func barRect(flipped: Bool) -> NSRect {
        
        if SystemUtils.isBigSur {
            return NSRect(x: 10, y: 2, width: 4, height: super.barRect(flipped: false).height)
        } else {
            return super.barRect(flipped: false)
        }
    }
    
    override internal func drawKnob(_ knobRect: NSRect) {
        
        let rectHeight = knobRect.height
        let bar = barRect(flipped: false).insetBy(dx: barInsetX, dy: barInsetY)
        let yCenter = knobRect.minY + (rectHeight / 2)

        let knobWidth: CGFloat = bar.width + knobWidthOutsideBar
        let knobMinY = yCenter - (knobHeight / 2)
        let rect = NSRect(x: bar.minX - ((knobWidth - bar.width) / 2), y: knobMinY, width: knobWidth, height: knobHeight)
        
        NSBezierPath.fillRoundedRect(rect, radius: knobRadius, withColor: knobColor)
    }
    
    override internal func drawBar(inside drawRect: NSRect, flipped: Bool) {
        
        let knobFrame = knobRect(flipped: false)
        let halfKnobWidth = knobFrame.width / 2
        
        let topRect = NSRect(x: drawRect.minX, y: drawRect.minY,
                             width: drawRect.width, height: knobFrame.minY + halfKnobWidth).insetBy(dx: barInsetX, dy: barInsetY)
        
        let bottomRect = NSRect(x: drawRect.minX, y: knobFrame.maxY - halfKnobWidth,
                                width: drawRect.width, height: drawRect.height - knobFrame.maxY + halfKnobWidth).insetBy(dx: barInsetX, dy: barInsetY)
        
        // Bottom rect
        NSBezierPath.fillRoundedRect(bottomRect, radius: barRadius, withGradient: foregroundGradient, angle: -.verticalGradientDegrees)
        
        // Top rect
        NSBezierPath.fillRoundedRect(topRect, radius: barRadius, withGradient: backgroundGradient, angle: -.verticalGradientDegrees)
        
        // Draw one tick across the center of the bar (marking 0dB)
        let tickMinX = drawRect.minX + tickInset
        let tickMaxX = drawRect.maxX - tickInset
        
        let tickRect = rectOfTickMark(at: 0)
        let tickY = tickRect.centerY
        
        // Tick
        GraphicsUtils.drawLine(Colors.Effects.sliderTickColor, pt1: NSMakePoint(tickMinX, tickY), pt2: NSMakePoint(tickMaxX, tickY),
                               width: tickWidth)
    }
    
    override func drawTickMarks() {
        // Do nothing (ticks are drawn in drawBar)
    }
}
