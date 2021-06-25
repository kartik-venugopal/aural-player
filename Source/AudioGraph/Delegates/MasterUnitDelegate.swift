//
//  MasterUnitDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class MasterUnitDelegate: EffectsUnitDelegate<MasterUnit>, MasterUnitDelegateProtocol {
    
    var presets: MasterPresets {return unit.presets}
    
    func applyPreset(_ preset: MasterPreset) {
        unit.applyPreset(preset)
    }
}
