import Foundation
import AVFoundation

class FXUnitPersistentState<T: EffectsUnitPresetPersistentState>: PersistentStateProtocol {
    
    var state: EffectsUnitState?
    var userPresets: [T]?
    
    init() {}
    
    required init?(_ map: NSDictionary) {
        
        self.state = map.enumValue(forKey: "state", ofType: EffectsUnitState.self)
        self.userPresets = map.arrayValue(forKey: "userPresets", ofType: T.self)
    }
}

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
        
        self.outputDevice = map.objectValue(forKey: "outputDevice", ofType: AudioDevicePersistentState.self)
        
        self.volume = map.floatValue(forKey: "volume")
        self.balance = map.floatValue(forKey: "balance")
        self.muted = map.boolValue(forKey: "muted")
        
        self.masterUnit = map.objectValue(forKey: "masterUnit", ofType: MasterUnitPersistentState.self)
        self.eqUnit = map.objectValue(forKey: "eqUnit", ofType: EQUnitPersistentState.self)
        self.pitchUnit = map.objectValue(forKey: "pitchUnit", ofType: PitchUnitPersistentState.self)
        self.timeUnit = map.objectValue(forKey: "timeUnit", ofType: TimeUnitPersistentState.self)
        self.reverbUnit = map.objectValue(forKey: "reverbUnit", ofType: ReverbUnitPersistentState.self)
        self.delayUnit = map.objectValue(forKey: "delayUnit", ofType: DelayUnitPersistentState.self)
        self.filterUnit = map.objectValue(forKey: "filterUnit", ofType: FilterUnitPersistentState.self)
        self.audioUnits = map.arrayValue(forKey: "audioUnits", ofType: AudioUnitPersistentState.self)
        self.soundProfiles = map.arrayValue(forKey: "soundProfiles", ofType: SoundProfilePersistentState.self)
    }
}
