import Foundation

class MasterUnitDelegate: FXUnitDelegate<MasterUnit>, MasterUnitDelegateProtocol {
    
    var presets: MasterPresets {return unit.presets}
    
    func applyPreset(_ preset: MasterPreset) {
        unit.applyPreset(preset)
    }
}
