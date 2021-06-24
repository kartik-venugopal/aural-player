//
//  FXUnitPresetPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class FXUnitPresetPersistentState: PersistentStateProtocol {
    
    let name: String
    let state: FXUnitState
    
    init(preset: FXUnitPreset) {
        
        self.name = preset.name
        self.state = preset.state
    }
    
    required init?(_ map: NSDictionary) {
      
        guard let name = map.nonEmptyStringValue(forKey: "name"),
              let state = map.enumValue(forKey: "state", ofType: FXUnitState.self) else {return nil}
        
        self.name = name
        self.state = state
    }
}
