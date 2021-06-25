//
//  EffectsUnitDelegateProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

///
/// A functional contract for an abstract delegate representing an effects unit.
///
/// Acts as a middleman between the Effects UI and an effects unit,
/// providing a simplified interface / facade for the UI layer to control an effects unit.
///
/// - SeeAlso: `MasterUnit`
///
protocol EffectsUnitDelegateProtocol {
    
    var state: EffectsUnitState {get}
    
    var stateFunction: EffectsUnitStateFunction {get}
    
    // Toggles the state of the pitch shift audio effects unit, and returns its new state
    func toggleState() -> EffectsUnitState
    
    var isActive: Bool {get}
    
    func ensureActive()
    
    func savePreset(_ presetName: String)
    
    func applyPreset(_ presetName: String)
}
