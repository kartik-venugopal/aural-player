//
//  EffectsUnitProtocol.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// A functional contract for an effects unit that processes audio.
///
protocol EffectsUnitProtocol {
    
    var unitType: EffectsUnitType {get}
    
    var state: EffectsUnitState {get}
    
    // Toggles the state of the effects unit, and returns its new state
    @discardableResult func toggleState() -> EffectsUnitState
    
    func ensureActive()
    
    var isActive: Bool {get}
    
    var stateFunction: EffectsUnitStateFunction {get}
    
    func suppress()
    
    func unsuppress()
    
    func reset()
    
    func ensureActiveAndReset()
    
    var renderQuality: Int {get set}
    
    var avNodes: [AVAudioNode] {get}
    
    func savePreset(named presetName: String)
    
    func applyPreset(named presetName: String)
    
    func observeState(handler: @escaping EffectsUnitStateChangeHandler) -> NSKeyValueObservation
}
