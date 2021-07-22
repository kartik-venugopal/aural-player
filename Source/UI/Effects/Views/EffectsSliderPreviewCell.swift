//
//  EffectsSliderPreviewCell.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class EffectsSliderPreviewCell: EffectsUnitSliderCell {
    
    override var knobColor: NSColor {
        
        switch self.unitState {
            
        case .active:   return Colors.Effects.defaultActiveUnitColor
            
        case .bypassed: return Colors.Effects.defaultBypassedUnitColor
            
        case .suppressed:   return Colors.Effects.defaultSuppressedUnitColor
            
        }
    }
    
    override var tickColor: NSColor {Colors.Effects.defaultTickColor}
    
    override var backgroundGradient: NSGradient {
        Colors.Effects.defaultSliderBackgroundGradient
    }
    
    override var foregroundGradient: NSGradient {
        
        switch self.unitState {
            
        case .active:   return Colors.Effects.defaultActiveSliderGradient
            
        case .bypassed: return Colors.Effects.defaultBypassedSliderGradient
            
        case .suppressed:   return Colors.Effects.defaultSuppressedSliderGradient
            
        }
    }
}
