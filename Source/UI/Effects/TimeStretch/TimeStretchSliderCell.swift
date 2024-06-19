//
//  TimeStretchSliderCell.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class TimeStretchSlider: EffectsUnitSlider {
    
    private let minRate: Float = 0.25
    
    /// Logarithmic scale.
    var rate: Float {
        
        get {
            minRate * powf(2, floatValue)
        }
        
        set(newRate) {
            floatValue = log2(newRate / minRate)
        }
    }
}
