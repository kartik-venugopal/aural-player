//
//  FilterBandSlider.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FilterBandSlider: RangeSlider, FXUnitStateObserver {
    
    var filterType: FilterBandType = .bandStop {
        didSet {redraw()}
    }
    
    var bandIndex: Int!
    
    var band: FilterBand {
        filterUnit[bandIndex]
    }
    
    private var filterUnit: FilterUnitProtocol! {
//        soundOrch.filterUnit
        nil
    }
    
    override var barFillColor: NSColor {
        
        let unitState = filterUnit.state
        let bandType = band.type

        if bandType == .bandStop || filterUnit[bandIndex].bypass {
            return systemColorScheme.inactiveControlColor
            
        } else {
            return unitState == .active ? systemColorScheme.activeControlColor : systemColorScheme.suppressedControlColor
        }
    }
    
    override var barBackgroundColor: NSColor {
        
        if band.type == .bandStop, !band.bypass, filterUnit.state == .active {
            return systemColorScheme.activeControlColor
        }

        return systemColorScheme.inactiveControlColor
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
