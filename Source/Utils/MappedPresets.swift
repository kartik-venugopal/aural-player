//
//  MappedPresets.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A contract for a generic preset that can be mapped to a key.
///
protocol MappedPreset {
    
    var key: String {get set}
    
    var userDefined: Bool {get}
}

///
/// A utility to perform CRUD operations on an ordered / mapped collection
/// of **MappedPreset** objects.
///
/// - SeeAlso: `MappedPreset`
///
class MappedPresets<P: MappedPreset> {
    
    private let userDefinedPresetsMap: PresetsMap<P> = PresetsMap()
    private let systemDefinedPresetsMap: PresetsMap<P> = PresetsMap()
    
    var userDefinedPresets: [P] {userDefinedPresetsMap.allPresets}
    var systemDefinedPresets: [P] {systemDefinedPresetsMap.allPresets}
    
    var defaultPreset: P? {nil}
    
    init(systemDefinedPresets: [P], userDefinedPresets: [P]) {
        
        systemDefinedPresets.forEach {
            self.systemDefinedPresetsMap.addPreset($0)
        }
        
        userDefinedPresets.forEach {
            self.userDefinedPresetsMap.addPreset($0)
        }
    }
    
    func addPreset(_ preset: P) {
        userDefinedPresetsMap.addPreset(preset)
    }
    
    func preset(named name: String) -> P? {
        systemDefinedPresetsMap[name] ?? userDefinedPresetsMap[name]
    }

    var numberOfUserDefinedPresets: Int {userDefinedPresetsMap.count}
    
    func userDefinedPreset(named name: String) -> P? {
        userDefinedPresetsMap[name]
    }
    
    func systemDefinedPreset(named name: String) -> P? {
        systemDefinedPresetsMap[name]
    }
    
    // TODO: All the delete functions should return the deleted elements.
    // This will require changes to the PresetsMap functions too.
    
    func deletePreset(atIndex index: Int) -> P {
        return userDefinedPresetsMap.removePresetAtIndex(index)
    }
    
    func deletePresets(atIndices indices: IndexSet) -> [P] {
        
        return indices.sorted(by: Int.descendingIntComparator).map {
            userDefinedPresetsMap.removePresetAtIndex($0)
        }
    }
    
    func deletePreset(named name: String) -> P? {
        return userDefinedPresetsMap.removePreset(withKey: name)
    }
    
    func deletePresets(named presetNames: [String]) -> [P] {
        
        return presetNames.compactMap {
            deletePreset(named: $0)
        }
    }
    
    func renamePreset(named oldName: String, to newName: String) {
        userDefinedPresetsMap.reMap(presetWithKey: oldName, toKey: newName)
    }
    
    func presetExists(named name: String) -> Bool {
        userDefinedPresetsMap.presetWithKeyExists(name) || systemDefinedPresetsMap.presetWithKeyExists(name)
    }
    
    func userDefinedPresetExists(named name: String) -> Bool {
        userDefinedPresetsMap.presetWithKeyExists(name)
    }
}

///
/// A specialized collection that functions as both an array and dictionary for **MappedPreset** objects
/// so that the presets can be accessed efficiently both by index and key.
///
fileprivate class PresetsMap<P: MappedPreset> {
    
    private var array: [P] = []
    private var map: [String: P] = [:]
    
    subscript(_ index: Int) -> P {
        array[index]
    }
    
    subscript(_ key: String) -> P? {
        map[key]
    }
    
    func addPreset(_ preset: P) {
        
        array.append(preset)
        map[preset.key] = preset
    }
    
    func removePreset(withKey key: String) -> P? {
        
        guard let index = array.firstIndex(where: {$0.key == key}) else {return nil}
        
        map.removeValue(forKey: key)
        return array.remove(at: index)
    }
    
    func reMap(presetWithKey oldKey: String, toKey newKey: String) {
        
        if var preset = map[oldKey] {

            // Modify the key within the preset
            preset.key = newKey
            
            // Re-map the preset to the new key
            map.removeValue(forKey: oldKey)
            map[newKey] = preset
        }
    }
    
    func removePresetAtIndex(_ index: Int) -> P {
        
        let preset = array[index]
        map.removeValue(forKey: preset.key)
        return array.remove(at: index)
    }
    
    func presetWithKeyExists(_ key: String) -> Bool {
        map[key] != nil
    }
    
    var count: Int {array.count}
    
    var allPresets: [P] {array}
}
