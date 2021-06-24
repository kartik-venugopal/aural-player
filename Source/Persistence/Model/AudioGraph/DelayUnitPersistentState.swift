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

class DelayUnitPersistentState: FXUnitPersistentState<DelayPresetPersistentState> {
    
    var amount: Float?
    var time: Double?
    var feedback: Float?
    var lowPassCutoff: Float?
    
    override init() {super.init()}
    
    required init?(_ map: NSDictionary) {
        
        super.init(map)
        
        self.amount = map["amount", Float.self]
        self.time = map["time", Double.self]
        self.feedback = map["feedback", Float.self]
        self.lowPassCutoff = map["lowPassCutoff", Float.self]
    }
}

class DelayPresetPersistentState: FXUnitPresetPersistentState {
    
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
        
        guard let amount = map["amount", Float.self],
              let time = map["time", Double.self],
              let feedback = map["feedback", Float.self],
              let lowPassCutoff = map["lowPassCutoff", Float.self] else {return nil}
        
        self.amount = amount
        self.time = time
        self.feedback = feedback
        self.lowPassCutoff = lowPassCutoff
        
        super.init(map)
    }
}
