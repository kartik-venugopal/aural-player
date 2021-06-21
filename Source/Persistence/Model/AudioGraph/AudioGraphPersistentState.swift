import Foundation

/*
 Encapsulates audio graph state
 */
class AudioGraphPersistentState: PersistentStateProtocol {
    
    var outputDevice: AudioDevicePersistentState?
    
    var volume: Float?
    var muted: Bool?
    var balance: Float?
    
    var masterUnit: MasterUnitPersistentState?
    var eqUnit: EQUnitPersistentState?
    var pitchUnit: PitchUnitPersistentState?
    var timeUnit: TimeUnitPersistentState?
    var reverbUnit: ReverbUnitPersistentState?
    var delayUnit: DelayUnitPersistentState?
    var filterUnit: FilterUnitPersistentState?
    var audioUnits: [AudioUnitPersistentState]?
    
    var soundProfiles: [SoundProfilePersistentState]?
    
    init() {}
    
    required init?(_ map: NSDictionary) {
        
        self.outputDevice = map.persistentObjectValue(forKey: "outputDevice", ofType: AudioDevicePersistentState.self)
        
        self.volume = map["volume", Float.self]
        self.balance = map["balance", Float.self]
        self.muted = map["muted", Bool.self]
        
        self.masterUnit = map.persistentObjectValue(forKey: "masterUnit", ofType: MasterUnitPersistentState.self)
        self.eqUnit = map.persistentObjectValue(forKey: "eqUnit", ofType: EQUnitPersistentState.self)
        self.pitchUnit = map.persistentObjectValue(forKey: "pitchUnit", ofType: PitchUnitPersistentState.self)
        self.timeUnit = map.persistentObjectValue(forKey: "timeUnit", ofType: TimeUnitPersistentState.self)
        self.reverbUnit = map.persistentObjectValue(forKey: "reverbUnit", ofType: ReverbUnitPersistentState.self)
        self.delayUnit = map.persistentObjectValue(forKey: "delayUnit", ofType: DelayUnitPersistentState.self)
        self.filterUnit = map.persistentObjectValue(forKey: "filterUnit", ofType: FilterUnitPersistentState.self)
        self.audioUnits = map.persistentObjectArrayValue(forKey: "audioUnits", ofType: AudioUnitPersistentState.self)
        self.soundProfiles = map.persistentObjectArrayValue(forKey: "soundProfiles", ofType: SoundProfilePersistentState.self)
    }
}
