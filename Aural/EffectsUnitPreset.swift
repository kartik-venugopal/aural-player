import Foundation

class EffectsUnitPreset {
    
    let name: String
    let systemDefined: Bool
    let state: EffectsUnitState
    
    init(_ name: String, _ state: EffectsUnitState, _ systemDefined: Bool) {
        
        self.name = name
        self.state = state
        self.systemDefined = systemDefined
    }
}
