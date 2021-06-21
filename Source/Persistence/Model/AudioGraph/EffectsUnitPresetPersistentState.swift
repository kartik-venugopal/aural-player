import Foundation

class EffectsUnitPresetPersistentState: PersistentStateProtocol {
    
    let name: String
    let state: EffectsUnitState
    
    init(preset: EffectsUnitPreset) {
        
        self.name = preset.name
        self.state = preset.state
    }
    
    required init?(_ map: NSDictionary) {
      
        guard let name = map.nonEmptyStringValue(forKey: "name"),
              let state = map.enumValue(forKey: "state", ofType: EffectsUnitState.self) else {return nil}
        
        self.name = name
        self.state = state
    }
}
