//
//  FXUnitPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class FXUnitPersistentState<T: FXUnitPresetPersistentState>: PersistentStateProtocol {
    
    var state: FXUnitState?
    var userPresets: [T]?
    
    init() {}
    
    required init?(_ map: NSDictionary) {
        
        self.state = map.enumValue(forKey: "state", ofType: FXUnitState.self)
        self.userPresets = map.persistentObjectArrayValue(forKey: "userPresets", ofType: T.self)
    }
}
