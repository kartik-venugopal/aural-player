import Foundation

protocol MappedPreset {
    
    var key: String {get set}
    
    var userDefined: Bool {get}
}

class MappedPresets<P> where P: MappedPreset {
    
    let userDefinedPresetsMap: PresetsMap<P> = PresetsMap()
    let systemDefinedPresetsMap: PresetsMap<P> = PresetsMap()
    
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
    
    func deletePreset(atIndex index: Int) {
        userDefinedPresetsMap.removePresetAtIndex(index)
    }
    
    func deletePresets(atIndices indices: IndexSet) {
        
        for index in indices.sorted(by: Int.descendingIntComparator) {
            userDefinedPresetsMap.removePresetAtIndex(index)
        }
    }
    
    func deletePreset(named name: String) {
        userDefinedPresetsMap.removePreset(withKey: name)
    }
    
    func deletePresets(named presetNames: [String]) {
        
        for name in presetNames {
            deletePreset(named: name)
        }
    }
    
    func renamePreset(named oldName: String, to newName: String) {
        userDefinedPresetsMap.reMap(presetWithKey: oldName, toKey: newName)
    }
    
    func presetExists(named name: String) -> Bool {
        return userDefinedPresetsMap.presetWithKeyExists(name) || systemDefinedPresetsMap.presetWithKeyExists(name)
    }
    
    func userDefinedPresetExists(named name: String) -> Bool {
        return userDefinedPresetsMap.presetWithKeyExists(name)
    }
}

class PresetsMap<P> where P: MappedPreset {
    
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
    
    func removePreset(withKey key: String) {
        
        if let index = array.firstIndex(where: {$0.key == key}) {
            
            array.remove(at: index)
            map.removeValue(forKey: key)
        }
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
    
    func removePresetAtIndex(_ index: Int) {
        
        guard array.indices.contains(index) else {return}
        
        let preset = array[index]
        map.removeValue(forKey: preset.key)
        array.remove(at: index)
    }
    
    func presetWithKeyExists(_ key: String) -> Bool {
        map[key] != nil
    }
    
    var count: Int {array.count}
    
    var allPresets: [P] {array}
    
    func removeAllPresets() {
        
        array.removeAll()
        map.removeAll()
    }
}
