//
//  ReplayGainUnitDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class ReplayGainUnitDelegate: EffectsUnitDelegate<ReplayGainUnit>, ReplayGainUnitDelegateProtocol {
    
    var mode: ReplayGainMode {
        
        get {unit.mode}
        set {unit.mode = newValue}
    }
    
    var preAmp: Float {
        
        get {unit.preAmp}
        set {unit.preAmp = newValue}
    }
    
    func applyGain(_ replayGain: ReplayGain?) {
        unit.replayGain = replayGain
    }
    
    var appliedGain: Float {
        unit.appliedGain
    }
    
    var hasAppliedGain: Bool {
        unit.replayGain != nil
    }
    
    var effectiveGain: Float {
        unit.effectiveGain
    }
}
