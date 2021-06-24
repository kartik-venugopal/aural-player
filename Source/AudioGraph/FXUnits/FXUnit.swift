//
//  FXUnit.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation
import AVFoundation

class FXUnit {
    
    var unitType: FXUnitType
    
    var state: FXUnitState {
        didSet {stateChanged()}
    }
    
    var stateFunction: FXUnitStateFunction {
        return {return self.state}
    }
    
    var avNodes: [AVAudioNode] {return []}
    
    var isActive: Bool {return state == .active}
    
    init(_ unitType: FXUnitType, _ state: FXUnitState) {
        
        self.unitType = unitType
        self.state = state
        stateChanged()
    }
    
    func stateChanged() {
        
        if isActive && unitType != .master {
            Messenger.publish(.fx_unitActivated)
        }
    }
    
    // Toggles the state of the effects unit, and returns its new state
    func toggleState() -> FXUnitState {
        
        state = state == .active ? .bypassed : .active
        return state
    }
    
    // TODO: There is a feedback loop going from slaveUnit -> masterUnit that results in this function being called
    // again a 2nd time from its first call. FIX IT !!!
    func ensureActive() {
        if !isActive {_ = toggleState()}
    }
    
    func suppress() {
        
        if state == .active {
            state = .suppressed
        }
    }
    
    func unsuppress() {
        
        if state == .suppressed {
            state = .active
        }
    }
    
    func reset() {}
    
    func savePreset(_ presetName: String) {}
    
    func applyPreset(_ presetName: String) {}
}
