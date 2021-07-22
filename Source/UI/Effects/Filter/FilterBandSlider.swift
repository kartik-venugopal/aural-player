//
//  FilterBandSlider.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FilterBandSlider: RangeSlider {
    
    var filterType: FilterBandType = .bandStop {
        didSet {redraw()}
    }
    
    override var barFillColor: NSColor {
        
        switch unitState {
            
        case .active:   return filterType == .bandPass ?
                                Colors.Effects.activeUnitStateColor :
                                Colors.Effects.bypassedUnitStateColor
            
        case .bypassed: return Colors.Effects.bypassedUnitStateColor
            
        case .suppressed:   return Colors.Effects.suppressedUnitStateColor
            
        }
    }
    
    override var knobColor: NSColor {
        
        switch unitState {
            
        case .active:   return filterType == .bandPass ?
                                Colors.Effects.activeUnitStateColor :
                                Colors.Effects.bypassedUnitStateColor
            
        case .bypassed: return Colors.Effects.bypassedUnitStateColor
            
        case .suppressed:   return Colors.Effects.suppressedUnitStateColor
            
        }
    }
    
    override var barBackgroundColor: NSColor {
        Colors.Effects.sliderBackgroundColor
    }
    
    var startFrequency: Float {
        Float(20 * pow(10, (start - 20) / 6660))
    }
    
    var endFrequency: Float {
        Float(20 * pow(10, (end - 20) / 6660))
    }
    
    func setFrequencyRange(_ min: Float, _ max: Float) {
        
        let temp = shouldTriggerHandler
        shouldTriggerHandler = false
        
        start = Double(6660 * log10(min/20) + 20)
        end = Double(6660 * log10(max/20) + 20)
        
        shouldTriggerHandler = temp
    }
}
