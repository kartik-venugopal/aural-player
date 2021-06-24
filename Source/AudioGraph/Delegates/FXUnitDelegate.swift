//
//  FXUnitDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class FXUnitDelegate<T: FXUnit>: FXUnitDelegateProtocol {
    
    var unit: T
    
    init(_ unit: T) {
        self.unit = unit
    }
    
    var state: EffectsUnitState {return unit.state}
    
    var stateFunction: EffectsUnitStateFunction {return unit.stateFunction}
    
    var isActive: Bool {return unit.isActive}
    
    func toggleState() -> EffectsUnitState {
        return unit.toggleState()
    }
    
    func ensureActive() {
        unit.ensureActive()
    }
    
    func savePreset(_ presetName: String) {
        unit.savePreset(presetName)
    }
    
    func applyPreset(_ presetName: String) {
        unit.applyPreset(presetName)
    }
}
