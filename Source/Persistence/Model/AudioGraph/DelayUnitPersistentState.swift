//
//  DelayUnitPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class DelayUnitPersistentState: EffectsUnitPersistentState<DelayPresetPersistentState> {
    
    var amount: Float?
    var time: Double?
    var feedback: Float?
    var lowPassCutoff: Float?
    
    override init() {super.init()}
    
    required init?(_ map: NSDictionary) {
        
        super.init(map)
        
        self.amount = map.floatValue(forKey: "amount")
        self.time = map.doubleValue(forKey: "time")
        self.feedback = map.floatValue(forKey: "feedback")
        self.lowPassCutoff = map.floatValue(forKey: "lowPassCutoff")
    }
}

class DelayPresetPersistentState: EffectsUnitPresetPersistentState {
    
    let amount: Float
    let time: Double
    let feedback: Float
    let lowPassCutoff: Float
    
    init(preset: DelayPreset) {
        
        self.amount = preset.amount
        self.time = preset.time
        self.feedback = preset.feedback
        self.lowPassCutoff = preset.lowPassCutoff
        
        super.init(preset: preset)
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let amount = map.floatValue(forKey: "amount"),
              let time = map.doubleValue(forKey: "time"),
              let feedback = map.floatValue(forKey: "feedback"),
              let lowPassCutoff = map.floatValue(forKey: "lowPassCutoff") else {return nil}
        
        self.amount = amount
        self.time = time
        self.feedback = feedback
        self.lowPassCutoff = lowPassCutoff
        
        super.init(map)
    }
}
