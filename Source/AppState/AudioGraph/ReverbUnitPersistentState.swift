//
//  ReverbUnitPersistentState.swift
//  Aural
//
//  Created by Kar Ven on 4/24/21.
//

import Foundation

class ReverbUnitState: FXUnitState<ReverbPresetState> {
    
    let space: ReverbSpaces?
    let amount: Float?
    
    required init?(_ map: NSDictionary) {
        
        super.init(map)
        
        self.space = map.enumValue(forKey: "space", ofType: ReverbSpaces.self)
        self.amount = map.floatValue(forKey: "amount")
    }
}

class ReverbPresetState: EffectsUnitPresetState {
    
    let space: ReverbSpaces
    let amount: Float
    
    required init?(_ map: NSDictionary) {
        
        super.init(map)
        
        guard let space = map.enumValue(forKey: "space", ofType: ReverbSpaces.self),
              let amount = map.floatValue(forKey: "amount") else {return nil}
        
        self.space = space
        self.amount = amount
    }
}
