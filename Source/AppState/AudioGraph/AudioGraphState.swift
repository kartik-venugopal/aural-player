import Foundation
import AVFoundation

class FXUnitState<T: EffectsUnitPresetState>: PersistentStateProtocol {
    
    let state: EffectsUnitState?
    let userPresets: [T]?
    
    required init?(_ map: NSDictionary) {
        
        self.state = map.enumValue(forKey: "state", ofType: EffectsUnitState.self)
        self.userPresets = map.arrayValue(forKey: "userPresets", ofType: T.self)
    }
}

class EffectsUnitPresetState: PersistentStateProtocol {
    
    let name: String
    let state: EffectsUnitState
    
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
class AudioGraphState: PersistentStateProtocol {
    
    let outputDevice: AudioDeviceState?
    
    let volume: Float?
    let muted: Bool?
    let balance: Float?
    
    let masterUnit: MasterUnitState?
    let eqUnit: EQUnitState?
    let pitchUnit: PitchUnitState?
    let timeUnit: TimeUnitState?
    let reverbUnit: ReverbUnitState?
    let delayUnit: DelayUnitState?
    let filterUnit: FilterUnitState?
    let audioUnits: [AudioUnitState]?
    
    let soundProfiles: [SoundProfilePersistentState]?
    
    required init?(_ map: NSDictionary) {
        
        self.outputDevice = map.objectValue(forKey: "outputDevice", ofType: AudioDeviceState.self)
        
        self.volume = map.floatValue(forKey: "volume")
        self.balance = map.floatValue(forKey: "balance")
        self.muted = map.boolValue(forKey: "muted")
        
        self.masterUnit = map.objectValue(forKey: "masterUnit", ofType: MasterUnitState.self)
        self.eqUnit = map.objectValue(forKey: "eqUnit", ofType: EQUnitState.self)
        self.pitchUnit = map.objectValue(forKey: "pitchUnit", ofType: PitchUnitState.self)
        self.timeUnit = map.objectValue(forKey: "timeUnit", ofType: TimeUnitState.self)
        self.reverbUnit = map.objectValue(forKey: "reverbUnit", ofType: ReverbUnitState.self)
        self.delayUnit = map.objectValue(forKey: "delayUnit", ofType: DelayUnitState.self)
        self.filterUnit = map.objectValue(forKey: "filterUnit", ofType: FilterUnitState.self)
        self.audioUnits = map.arrayValue(forKey: "audioUnits", ofType: AudioUnitState.self)
        self.soundProfiles = map.arrayValue(forKey: "soundProfiles", ofType: SoundProfilePersistentState.self)
    }
}
