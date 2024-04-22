//
//  HorizontalSymmetricSliderCell.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class HorizontalSymmetricSliderCell: HorizontalSliderCell {
    
    override var knobHeightOutsideBar: CGFloat {3.5}
    
    override func progressRect(forBarRect barRect: NSRect, andKnobRect knobRect: NSRect) -> NSRect {
        
        // Draw rect between knob and center, to show panning
        let knobCenter = knobRect.centerX
        let barCenter = barRect.centerX
        let panRectX = min(knobCenter, barCenter)
        let panRectWidth = abs(knobCenter - barCenter)
        
        return NSRect(x: panRectX, y: barRect.minY, width: panRectWidth, height: barRect.height)
    }
    
    override func drawProgress(inRect rect: NSRect) {
        
        if rect.width > 0 {
            super.drawProgress(inRect: rect)
        }
    }
    
    override func knobRect(flipped: Bool) -> NSRect {
        
        let bar = barRect(flipped: flipped)
        let startX = bar.minX + (progress * bar.width)
        let xOffset = -(progress * knobWidth)
        
        let newX = startX + xOffset
        let newY = bar.minY - knobHeightOutsideBar
        
        return NSRect(x: newX, y: newY, width: knobWidth, height: knobHeightOutsideBar * 2 + bar.height)
    }
}

class SymmetricEffectsUnitSliderCell: HorizontalSymmetricSliderCell {
    
    lazy var observingSlider: EffectsUnitSlider = controlView as! EffectsUnitSlider
    
    override var controlStateColor: NSColor {
        systemColorScheme.colorForEffectsUnitState(fxUnitStateObserverRegistry.currentState(forObserver: observingSlider))
    }
}
