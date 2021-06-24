//
//  ReverbUnitPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class ReverbUnitPersistentState: FXUnitPersistentState<ReverbPresetPersistentState> {
    
    var space: ReverbSpaces?
    var amount: Float?
    
    override init() {super.init()}
    
    required init?(_ map: NSDictionary) {
        
        self.space = map.enumValue(forKey: "space", ofType: ReverbSpaces.self)
        self.amount = map["amount", Float.self]
        
        super.init(map)
    }
}

class ReverbPresetPersistentState: EffectsUnitPresetPersistentState {
    
    let space: ReverbSpaces
    let amount: Float
    
    init(preset: ReverbPreset) {
        
        self.space = preset.space
        self.amount = preset.amount
        
        super.init(preset: preset)
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let space = map.enumValue(forKey: "space", ofType: ReverbSpaces.self),
              let amount = map["amount", Float.self] else {return nil}
        
        self.space = space
        self.amount = amount
        
        super.init(map)
    }
}
