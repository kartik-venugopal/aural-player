//
//  PresetsWrapper.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

protocol PresetsWrapperProtocol {
    
    var userDefinedPresets: [FXUnitPreset] {get}
    var systemDefinedPresets: [FXUnitPreset] {get}
    
    func preset(named name: String) -> FXUnitPreset?
    
    func deletePresets(atIndices indices: IndexSet)
    
    func renamePreset(named oldName: String, to newName: String)
    
    func presetExists(named name: String) -> Bool
}

class PresetsWrapper<T: FXUnitPreset, U: FXPresets<T>>: PresetsWrapperProtocol {
    
    private let presets: U
    
    init(_ presets: U) {
        self.presets = presets
    }
    
    var userDefinedPresets: [FXUnitPreset] {
        return presets.userDefinedPresets
    }
    var systemDefinedPresets: [FXUnitPreset] {
        return presets.systemDefinedPresets
    }
    
    func preset(named name: String) -> FXUnitPreset? {
        return presets.preset(named: name)
    }
    
    func deletePresets(atIndices indices: IndexSet) {
        presets.deletePresets(atIndices: indices)
    }
    
    func renamePreset(named oldName: String, to newName: String) {
        presets.renamePreset(named: oldName, to: newName)
    }
    
    func presetExists(named name: String) -> Bool {
        return presets.presetExists(named: name)
    }
}
