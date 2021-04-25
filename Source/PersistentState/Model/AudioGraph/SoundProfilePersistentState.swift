import Foundation

class SoundProfilePersistentState: PersistentStateProtocol {
    
    let file: URL
    
    let volume: Float
    let balance: Float
    
    let effects: MasterPresetPersistentState
    
    init(file: URL, volume: Float, balance: Float, effects: MasterPresetPersistentState) {
        
        self.file = file
        self.volume = volume
        self.balance = balance
        self.effects = effects
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let file = map.urlValue(forKey: "file"),
              let volume = map.floatValue(forKey: "volume"),
              let balance = map.floatValue(forKey: "balance"),
              let effects = map.objectValue(forKey: "effects", ofType: MasterPresetPersistentState.self) else {return nil}
        
        self.file = file
        self.volume = volume
        self.balance = balance
        self.effects = effects
    }
}
