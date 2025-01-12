//
//  EQSliderCell.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Customizes the look and feel of the parametric EQ sliders
 */
class EQSliderCell: AuralSliderCell {
    
    lazy var observingSlider: EffectsUnitSlider = controlView as! EffectsUnitSlider
    
    override var controlStateColor: NSColor {
        systemColorScheme.colorForEffectsUnitState(fxUnitStateObserverRegistry.currentState(forObserver: observingSlider))
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Constants
    
    override var barRadius: CGFloat {0}
    var barWidth: CGFloat {3}
    
    override var knobRadius: CGFloat {1}
    
    private let tickInset: CGFloat = 1.5
    override var tickWidth: CGFloat {2}
    
    private let knobHeight: CGFloat = 12
    private let knobWidthOutsideBar: CGFloat = 1.75
    
    // ------------------------------------------------------------------------
    
    // MARK: Rendering
    
    // Force knobRect and barRect to NOT be flipped
    
    override func barRect(flipped: Bool) -> NSRect {
        
        let superRect = originalBarRect
        let diff = superRect.width - barWidth
        
        return superRect.insetBy(dx: diff / 2, dy: 0)
    }
    
    override internal func drawKnob(_ knobRect: NSRect) {
        
        let rectHeight = knobRect.height
        let bar = barRect(flipped: false)
        let yCenter = knobRect.minY + (rectHeight / 2)

        let knobWidth: CGFloat = bar.width + knobWidthOutsideBar * 2
        let knobMinY = yCenter - (knobHeight / 2)
        let rect = NSRect(x: bar.minX - ((knobWidth - bar.width) / 2), y: knobMinY, width: knobWidth, height: knobHeight)

        NSBezierPath.fillRoundedRect(rect, radius: knobRadius, withColor: controlStateColor)
        NSBezierPath.strokeRoundedRect(rect, radius: knobRadius, withColor: systemColorScheme.backgroundColor, lineWidth: 2)
    }
    
    override internal func drawBar(inside drawRect: NSRect, flipped: Bool) {
        
        let knobFrame = knobRect(flipped: false)
        let progressRect = NSRect(x: drawRect.minX, y: drawRect.minY,
                                width: drawRect.width, height: knobFrame.centerY - drawRect.minY)
        
        // Background line
        let startPoint = NSMakePoint(drawRect.centerX, drawRect.minY)
        let endPoint = NSMakePoint(drawRect.centerX, drawRect.maxY)
        GraphicsUtils.drawLine(systemColorScheme.inactiveControlColor, pt1: startPoint, pt2: endPoint, width: 1)
        
        // Progress rect
        NSBezierPath.fillRoundedRect(progressRect, radius: barRadius, withColor: controlStateColor)
        
        // Draw one tick across the center of the bar (marking 0dB)
        let tickMinX = drawRect.minX + tickInset
        let tickMaxX = drawRect.maxX - tickInset
        
        let tickRect = rectOfTickMark(at: 0)
        let tickY = tickRect.centerY
        
        // Tick
        GraphicsUtils.drawLine(.black, pt1: NSMakePoint(tickMinX, tickY), pt2: NSMakePoint(tickMaxX, tickY),
                               width: tickWidth)
    }
    
    override func knobRect(flipped: Bool) -> NSRect {
        originalKnobRect
    }
    
    override func drawTickMarks() {
        // Do nothing (ticks are drawn in drawBar)
    }
}
