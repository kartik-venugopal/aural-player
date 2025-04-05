//
//  EffectsUnitPresets.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A functional contract for a mapped collection of presets that can be applied to an effects unit.
///
protocol EffectsUnitPresetsProtocol {
    
    associatedtype T: EffectsUnitPreset
    
    var userDefinedObjects: [T] {get}
    var systemDefinedObjects: [T] {get}
    
    func object(named name: String) -> T?
    
    func deleteObjects(named presetNames: [String]) -> [T]
    
    func renameObject(named oldName: String, to newName: String)
    
    func addObject(_ preset: T)
    
    func objectExists(named name: String) -> Bool
}

///
/// A base class for a mapped collection of presets that can be applied to an effects unit.
///
/// No instances of this type are to be used directly, as this class is only intended to be used as a base
/// class for concrete effects unit presets collections.
///
class EffectsUnitPresets<T: EffectsUnitPreset>: UserManagedObjects<T>, EffectsUnitPresetsProtocol {}

///
/// A base class for a single preset that can be applied to an effects unit.
///
class EffectsUnitPreset: UserManagedObject {
    
    var name: String
    
    var key: String {
        
        get {name}
        set {name = newValue}
    }
    
    var userDefined: Bool {!systemDefined}
    
    let systemDefined: Bool
    var state: EffectsUnitState
    
    init(name: String, state: EffectsUnitState, systemDefined: Bool) {
        
        self.name = name
        self.state = state
        self.systemDefined = systemDefined
    }
}
