import Foundation

protocol FXPresetsProtocol {
    
    associatedtype T: EffectsUnitPreset
    
    var userDefinedPresets: [T] {get}
    var systemDefinedPresets: [T] {get}
    
    func presetByName(_ name: String) -> T?
    
    func deletePresets(_ presetNames: [String])
    
    func renamePreset(_ oldName: String, _ newName: String)
    
    func addPresets(_ presetsArr: [T])
    
    func addPreset(_ preset: T)
    
    func presetWithNameExists(_ name: String) -> Bool
}

class FXPresets<T: EffectsUnitPreset>: FXPresetsProtocol {
    
    private var map: [String: T] = [:]
    
    private(set) var userDefinedPresets: [T] = []
    private(set) var systemDefinedPresets: [T] = []
    
    func presetWithNameExists(_ name: String) -> Bool {
        return map[name] != nil
    }
    
    func presetByName(_ name: String) -> T? {
        return map[name]
    }
    
    func renamePreset(_ oldName: String, _ newName: String) {
        
        if let preset = presetByName(oldName) {
            
            map.removeValue(forKey: oldName)
            preset.name = newName
            map[newName] = preset
        }
    }
    
    func addPresets(_ presetsArr: [T]) {
        presetsArr.forEach({addPreset($0)})
    }
    
    // Assume preset with this name doesn't already exist
    func addPreset(_ preset: T) {
        
        map[preset.name] = preset
        preset.systemDefined ? systemDefinedPresets.append(preset) : userDefinedPresets.append(preset)
    }
    
    func deletePresets(_ presetNames: [String]) {
        
        for presetName in presetNames {
            
            if map[presetName] != nil {
                
                map[presetName] = nil
                
                // Remove from user defined presets (system-defined presets cannot be deleted)
                if let index = userDefinedPresets.firstIndex(where: {$0.name == presetName}) {
                    userDefinedPresets.remove(at: index)
                }
            }
        }
    }
}
