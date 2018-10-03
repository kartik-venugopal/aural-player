import Foundation

class ReverbPresets {
    
    private static var presets: [String: ReverbPreset] = [String: ReverbPreset]()
    
    static func presetByName(_ name: String) -> ReverbPreset? {
        return presets[name]
    }
    
    static func allPresets() -> [ReverbPreset] {
        
        var allPresets = [ReverbPreset]()
        allPresets.append(contentsOf: presets.values)
        
        return allPresets
    }
    
    static func loadPresets(_ userDefinedPresets: [ReverbPreset]) {
        userDefinedPresets.forEach({presets[$0.name] = $0})
    }
    
    // Assume preset with this name doesn't already exist
    static func addUserDefinedPreset(_ name: String, _ state: EffectsUnitState, _ space: ReverbSpaces, _ amount: Float) {
        presets[name] = ReverbPreset(name, state, space, amount, false)
    }
    
    static func presetWithNameExists(_ name: String) -> Bool {
        return presets[name] != nil
    }
}

class ReverbPreset: EffectsUnitPreset {
    
    let space: ReverbSpaces
    let amount: Float
    
    init(_ name: String, _ state: EffectsUnitState, _ space: ReverbSpaces, _ amount: Float, _ systemDefined: Bool) {
        
        self.space = space
        self.amount = amount
        super.init(name, state, systemDefined)
    }
}
