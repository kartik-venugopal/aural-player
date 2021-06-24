//
//  FXUnitSlider.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

protocol FXUnitSliderProtocol {
    
    var unitState: FXUnitState {get set}
    var stateFunction: (() -> FXUnitState)? {get set}
    
    func updateState()
}

protocol FXUnitSliderCellProtocol {
    
    var unitState: FXUnitState {get set}
}

class FXUnitSlider: NSSlider, FXUnitSliderProtocol {
    
    var unitState: FXUnitState = .bypassed
    var stateFunction: (() -> FXUnitState)?
    
    func updateState() {
        
        if let function = stateFunction {
            
            unitState = function()
            
            if var cell = self.cell as? FXUnitSliderCellProtocol {
                cell.unitState = unitState
            }
            
            redraw()
        }
    }
    
    func setUnitState(_ state: FXUnitState) {
        
        self.unitState = state
        
        if var cell = self.cell as? FXUnitSliderCellProtocol {
            cell.unitState = unitState
        }
        
        redraw()
    }
}
