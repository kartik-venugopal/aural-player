//
//  FilterPreviewChart.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class FilterPreviewChart: FilterChart {
    
    override var inactiveUnitGradient: NSGradient {
        Colors.Effects.defaultSliderBackgroundGradient
    }
    
    override var bandStopGradient: NSGradient {
        Colors.Effects.defaultBypassedSliderGradient
    }
    
    override var bandPassGradient: NSGradient {
        Colors.Effects.defaultActiveSliderGradient
    }
    
    override var backgroundColor: NSColor {.black}
    
    override var textColor: NSColor {.white}
}
