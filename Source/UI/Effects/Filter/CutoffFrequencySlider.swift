//
//  CutoffFrequencySlider.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class CutoffFrequencySlider: EffectsUnitSlider {
    
    var frequency: Float {
        20 * powf(10, (floatValue - 20) / 6660)
    }
    
    func setFrequency(_ freq: Float) {
        self.floatValue = 6660 * log10(freq / 20) + 20
    }
}

class CutoffFrequencySliderCell: EffectsUnitSliderCell {
    
    var filterType: FilterBandType = .lowPass
    
    override var backgroundGradient: NSGradient {
        
        if filterType == .lowPass {
            return Colors.Effects.sliderBackgroundGradient
        }
        
        switch (unitState, filterType) {
        
        case (.active, .highPass):  return Colors.Effects.activeSliderGradient.reversed()
            
        case (.bypassed, .highPass):  return Colors.Effects.bypassedSliderGradient.reversed()
            
        case (.suppressed, .highPass):  return Colors.Effects.suppressedSliderGradient.reversed()
            
        default:    return Colors.Effects.sliderBackgroundGradient
            
        }
    }
    
    override var foregroundGradient: NSGradient {
        
        if filterType == .highPass {
            return Colors.Effects.sliderBackgroundGradient.reversed()
        }
        
        switch (unitState, filterType) {
        
        case (.active, .lowPass):  return Colors.Effects.activeSliderGradient
            
        case (.bypassed, .lowPass):  return Colors.Effects.bypassedSliderGradient
            
        case (.suppressed, .lowPass):  return Colors.Effects.suppressedSliderGradient
            
        default:    return Colors.Effects.sliderBackgroundGradient.reversed()
            
        }
    }
}

class FilterCutoffFrequencySliderCell: CutoffFrequencySliderCell {
}
