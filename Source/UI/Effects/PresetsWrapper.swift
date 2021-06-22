import Foundation

protocol PresetsWrapperProtocol {
    
    var userDefinedPresets: [EffectsUnitPreset] {get}
    var systemDefinedPresets: [EffectsUnitPreset] {get}
    
    func preset(named name: String) -> EffectsUnitPreset?
    
    func deletePresets(atIndices indices: IndexSet)
    
    func renamePreset(named oldName: String, to newName: String)
    
    func presetExists(named name: String) -> Bool
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
    
    func preset(named name: String) -> EffectsUnitPreset? {
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
