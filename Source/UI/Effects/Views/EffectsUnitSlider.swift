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
    
    var unitState: EffectsUnitState {get}
    var stateFunction: (() -> EffectsUnitState)? {get set}
    
    func updateState()
}

protocol EffectsUnitSliderCellProtocol {
    
    var unitState: EffectsUnitState {get set}
}

class EffectsUnitSlider: NSSlider, EffectsUnitSliderProtocol {
    
    private(set) var unitState: EffectsUnitState = .bypassed
    
    var stateFunction: (() -> EffectsUnitState)? {
        didSet {updateState()}
    }
    
    var effectsCell: EffectsUnitSliderCellProtocol!
    
    override func awakeFromNib() {
        self.effectsCell = (self.cell as! EffectsUnitSliderCellProtocol)
    }
    
    func updateState() {
        
        guard let stateFunction = self.stateFunction else {return}
        
        unitState = stateFunction()
        effectsCell.unitState = unitState
        redraw()
    }
    
    func setUnitState(_ state: EffectsUnitState) {
        
        self.unitState = state
        effectsCell.unitState = unitState
        redraw()
    }
}
