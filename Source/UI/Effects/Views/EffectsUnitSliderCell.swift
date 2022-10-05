//
//  EffectsUnitSliderCell.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

// Cell for all ticked effects sliders
class EffectsUnitSliderCell: TickedSliderCell, EffectsUnitSliderCellProtocol {
    
    override var barRadius: CGFloat {1.5}
    override var barInsetY: CGFloat {System.isBigSur ? 0 : 0.5}
    
    override var knobWidth: CGFloat {10}
    override var knobRadius: CGFloat {1}
    override var knobHeightOutsideBar: CGFloat {2}
    
    override var knobColor: NSColor {
        Colors.Effects.sliderKnobColorForState(self.unitState)
    }
    
    override var tickColor: NSColor {Colors.Effects.sliderTickColor}
    
    override var tickVerticalSpacing: CGFloat {1}
    
    override var backgroundGradient: NSGradient {
        Colors.Effects.sliderBackgroundGradient
    }
    
    override var foregroundGradient: NSGradient {
     
        switch self.unitState {
            
        case .active:   return Colors.Effects.activeSliderGradient
            
        case .bypassed: return Colors.Effects.bypassedSliderGradient
            
        case .suppressed:   return Colors.Effects.suppressedSliderGradient
            
        }
    }
    
    var unitState: EffectsUnitState = .bypassed
    
    override func barRect(flipped: Bool) -> NSRect {
        
        if System.isBigSur {
            return NSRect(x: 2, y: 4, width: super.barRect(flipped: flipped).width, height: 4)
        } else {
            return super.barRect(flipped: flipped)
        }
    }
}
