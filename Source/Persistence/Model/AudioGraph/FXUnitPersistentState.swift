import Foundation

class FXUnitPersistentState<T: EffectsUnitPresetPersistentState>: PersistentStateProtocol {
    
    var state: EffectsUnitState?
    var userPresets: [T]?
    
    init() {}
    
    required init?(_ map: NSDictionary) {
        
        self.state = map.enumValue(forKey: "state", ofType: EffectsUnitState.self)
        self.userPresets = map.persistentObjectArrayValue(forKey: "userPresets", ofType: T.self)
    }
}
