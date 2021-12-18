//
//  EffectsUnitPresets+Extensions.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

extension EffectsUnitPresets {
    
    var numberOfUserDefinedPresets: Int {
        numberOfUserDefinedObjects
    }
    
    var userDefinedPresets: [T] {
        userDefinedObjects
    }
    
    func userDefinedPreset(named presetName: String) -> T? {
        userDefinedObject(named: presetName)
    }
}
