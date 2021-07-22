//
//  EffectsUnitDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// An abstract delegate representing an effects unit.
///
/// Acts as a middleman between the Effects UI and an effects unit,
/// providing a simplified interface / facade for the UI layer to control an effects unit.
///
/// No instances of this type are to be used directly, as this class is only intended to be used as a base
/// class for concrete effects units delegates.
///
/// - SeeAlso: `EffectsUnitDelegateProtocol`
/// - SeeAlso: `EffectsUnit`
///
class EffectsUnitDelegate<T: EffectsUnit>: EffectsUnitDelegateProtocol {
    
    var unit: T
    
    init(for unit: T) {
        self.unit = unit
    }
    
    var unitType: EffectsUnitType {unit.unitType}
    
    var state: EffectsUnitState {unit.state}
    
    var stateFunction: EffectsUnitStateFunction {unit.stateFunction}
    
    var isActive: Bool {unit.isActive}
    
    func toggleState() -> EffectsUnitState {
        unit.toggleState()
    }
    
    func ensureActive() {
        unit.ensureActive()
    }
    
    func savePreset(named presetName: String) {
        unit.savePreset(named: presetName)
    }
    
    // FIXME: Ensure unit active.
    func applyPreset(named presetName: String) {
        
        unit.applyPreset(named: presetName)
//        unit.ensureActive()
    }
}
