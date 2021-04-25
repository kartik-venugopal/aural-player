import Foundation

class EffectsUnitPreset {
    
    var name: String
    let systemDefined: Bool
    var state: EffectsUnitState
    
    init(_ name: String, _ state: EffectsUnitState, _ systemDefined: Bool) {
        
        self.name = name
        self.state = state
        self.systemDefined = systemDefined
    }
    
    init(persistentState: EffectsUnitPresetState) {
        
        self.name = persistentState.name
        self.state = persistentState.state
        self.systemDefined = false
    }
}
