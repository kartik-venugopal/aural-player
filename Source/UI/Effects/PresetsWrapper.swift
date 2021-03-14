import Foundation

protocol PresetsWrapperProtocol {
    
    var userDefinedPresets: [EffectsUnitPreset] {get}
    var systemDefinedPresets: [EffectsUnitPreset] {get}
    
    func presetByName(_ name: String) -> EffectsUnitPreset?
    
    func deletePresets(_ presetNames: [String])
    
    func renamePreset(_ oldName: String, _ newName: String)
    
    func presetWithNameExists(_ name: String) -> Bool
}

class PresetsWrapper<T: EffectsUnitPreset, U: FXPresets<T>>: PresetsWrapperProtocol {
    
    private let presets: U
    
    init(_ presets: U) {
        self.presets = presets
    }
    
    var userDefinedPresets: [EffectsUnitPreset] {
        return presets.userDefinedPresets
    }
    var systemDefinedPresets: [EffectsUnitPreset] {
        return presets.systemDefinedPresets
    }
    
    func presetByName(_ name: String) -> EffectsUnitPreset? {
        return presets.presetByName(name)
    }
    
    func deletePresets(_ presetNames: [String]) {
        presets.deletePresets(presetNames)
    }
    
    func renamePreset(_ oldName: String, _ newName: String) {
        presets.renamePreset(oldName, newName)
    }
    
    func presetWithNameExists(_ name: String) -> Bool {
        return presets.presetWithNameExists(name)
    }
}
