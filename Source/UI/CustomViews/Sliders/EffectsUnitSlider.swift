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

protocol EffectsUnitSliderProtocol {
    
    var unitState: EffectsUnitState {get set}
    var stateFunction: (() -> EffectsUnitState)? {get set}
    
    func updateState()
}

protocol EffectsUnitSliderCellProtocol {
    
    var unitState: EffectsUnitState {get set}
}

class EffectsUnitSlider: NSSlider, EffectsUnitSliderProtocol {
    
    var unitState: EffectsUnitState = .bypassed
    var stateFunction: (() -> EffectsUnitState)?
    
    func updateState() {
        
        if let function = stateFunction {
            
            unitState = function()
            
            if var cell = self.cell as? EffectsUnitSliderCellProtocol {
                cell.unitState = unitState
            }
            
            redraw()
        }
    }
    
    func setUnitState(_ state: EffectsUnitState) {
        
        self.unitState = state
        
        if var cell = self.cell as? EffectsUnitSliderCellProtocol {
            cell.unitState = unitState
        }
        
        redraw()
    }
}
