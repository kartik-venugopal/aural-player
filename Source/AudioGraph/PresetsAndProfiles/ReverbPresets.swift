import Foundation

class ReverbPresets: FXPresets<ReverbPreset> {}

class ReverbPreset: EffectsUnitPreset {
    
    let space: ReverbSpaces
    let amount: Float
    
    init(_ name: String, _ state: EffectsUnitState, _ space: ReverbSpaces, _ amount: Float, _ systemDefined: Bool) {
        
        self.space = space
        self.amount = amount
        super.init(name, state, systemDefined)
    }
    
    init(persistentState: ReverbPresetState) {
        
        self.space = persistentState.space
        self.amount = persistentState.amount
        super.init(persistentState.name, persistentState.state, false)
    }
}
