import Foundation

class MasterUnitDelegate: FXUnitDelegate<MasterUnit>, MasterUnitDelegateProtocol {
    
    let graph: AudioGraphProtocol
    var presets: MasterPresets {return unit.presets}
    
    init(_ graph: AudioGraphProtocol) {
        
        self.graph = graph
        super.init(graph.masterUnit)
    }
    
    func applyPreset(_ preset: MasterPreset) {
        unit.applyPreset(preset)
    }
}
