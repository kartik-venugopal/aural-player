//
//  FXPresets.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

protocol FXPresetsProtocol {
    
    associatedtype T: FXUnitPreset
    
    var userDefinedPresets: [T] {get}
    var systemDefinedPresets: [T] {get}
    
    func preset(named name: String) -> T?
    
    func deletePresets(named presetNames: [String])
    
    func renamePreset(named oldName: String, to newName: String)
    
    func addPreset(_ preset: T)
    
    func presetExists(named name: String) -> Bool
}

class FXPresets<T: FXUnitPreset>: MappedPresets<T>, FXPresetsProtocol {
}

class FXUnitPreset: MappedPreset {
    
    var name: String
    
    var key: String {
        
        get {name}
        set {name = newValue}
    }
    
    var userDefined: Bool {!systemDefined}
    
    let systemDefined: Bool
    var state: FXUnitState
    
    init(_ name: String, _ state: FXUnitState, _ systemDefined: Bool) {
        
        self.name = name
        self.state = state
        self.systemDefined = systemDefined
    }
    
    init(persistentState: FXUnitPresetPersistentState) {
        
        self.name = persistentState.name
        self.state = persistentState.state
        self.systemDefined = false
    }
}
