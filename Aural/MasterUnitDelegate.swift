import Foundation

class MasterUnitDelegate: FXUnitDelegate<MasterUnit> {
    
    let graph: AudioGraphProtocol
    let soundPreferences: SoundPreferences
    
    init(_ graph: AudioGraphProtocol, _ soundPreferences: SoundPreferences) {
        
        self.graph = graph
        self.soundPreferences = soundPreferences
        super.init(graph.masterUnit)
        
        if soundPreferences.effectsSettingsOnStartupOption == .applyMasterPreset, let presetName = soundPreferences.masterPresetOnStartup_name {
            self.applyPreset(presetName)
        }
    }
    
    func applyPreset(_ preset: MasterPreset) {
        unit.applyPreset(preset)
    }
}
