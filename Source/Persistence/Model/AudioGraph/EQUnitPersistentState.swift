//
//  EQUnitPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class EQUnitPersistentState: FXUnitPersistentState<EQPresetPersistentState> {
    
    var type: EQType?
    var globalGain: Float?
    var bands: [Float]?
    
    override init() {super.init()}
    
    required init?(_ map: NSDictionary) {
        
        super.init(map)
        
        self.type = map.enumValue(forKey: "type", ofType: EQType.self)
        self.bands = map["bands", [Float].self]
        self.globalGain = map["globalGain", Float.self]
    }
}

class EQPresetPersistentState: FXUnitPresetPersistentState {
    
    let bands: [Float]
    let globalGain: Float?
    
    init(preset: EQPreset) {
        
        self.bands = preset.bands
        self.globalGain = preset.globalGain
        
        super.init(preset: preset)
    }
    
    required init?(_ map: NSDictionary) {

        guard let bands = map["bands", [Float].self] else {return nil}
        
        self.bands = bands
        self.globalGain = map["globalGain", Float.self]
        
        super.init(map)
    }
}
