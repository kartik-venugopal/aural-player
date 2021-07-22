//
//  EffectsUnitSlider.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class EffectsUnitSlider: NSSlider {
    
    private(set) var unitState: EffectsUnitState = .bypassed
    var stateFunction: (() -> EffectsUnitState)?
    
    func updateState() {
        
        if let function = stateFunction {
            
            unitState = function()
            
            if let cell = self.cell as? EffectsUnitSliderCell {
                cell.unitState = unitState
            }
            
            redraw()
        }
    }
    
    func setUnitState(_ state: EffectsUnitState) {
        
        self.unitState = state
        
        if let cell = self.cell as? EffectsUnitSliderCell {
            cell.unitState = unitState
        }
        
        redraw()
    }
}
