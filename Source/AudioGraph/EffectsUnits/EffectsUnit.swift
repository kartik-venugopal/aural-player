//
//  EffectsUnit.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// An abstract representation of (base class for) an effects unit that processes audio. It contains
/// properties and functions common to all effects units - eg. unit state.
///
/// No instances of this type are to be used directly, as this class is only intended to be used as a base
/// class for concrete effects unit classes.
///
class EffectsUnit {
    
    var unitType: EffectsUnitType
    
    var state: EffectsUnitState {
        didSet {stateChanged()}
    }
    
    var stateFunction: EffectsUnitStateFunction {
        {self.state}
    }
    
    private var stateChangeRequiresNotification: Bool = true
    
    // Intended to be overriden by subclasses.
    var avNodes: [AVAudioNode] {[]}
    
    var isActive: Bool {state == .active}
    
    lazy var messenger = Messenger(for: self)
    
    init(unitType: EffectsUnitType, unitState: EffectsUnitState) {
        
        self.unitType = unitType
        self.state = unitState
        stateChanged()
    }
    
    func stateChanged() {
        
        if stateChangeRequiresNotification, isActive, unitType != .master {
            messenger.publish(.effects_unitActivated)
        }
    }
    
    // Toggles the state of the effects unit, and returns its new state
    func toggleState() -> EffectsUnitState {
        
        state = state == .active ? .bypassed : .active
        return state
    }
    
    func ensureActive() {
        
        if !isActive {
            _ = toggleState()
        }
    }
    
    func suppress() {
        
        if state == .active {
            
            // FIXME - Must call stateChanged() here, but somehow prevent the message
            // from being published.
            changeStateWithoutNotifying(to: .suppressed)
        }
    }
    
    func unsuppress() {
        
        if state == .suppressed {
            
            // FIXME - Must call stateChanged() here, but somehow prevent the message
            // from being published.
            changeStateWithoutNotifying(to: .active)
        }
    }
    
    private func changeStateWithoutNotifying(to newState: EffectsUnitState) {
        
        stateChangeRequiresNotification = false
        state = newState
        stateChangeRequiresNotification = true
    }
    
    // Intended to be overriden by subclasses.
    func reset() {}
    
    // Intended to be overriden by subclasses.
    func savePreset(named presetName: String) {}
    
    // Intended to be overriden by subclasses.
    func applyPreset(named presetName: String) {}
}
