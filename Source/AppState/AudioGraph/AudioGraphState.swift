import Foundation
import AVFoundation

class FXUnitState<T: EffectsUnitPresetState>: PersistentStateProtocol {
    
    var state: EffectsUnitState?
    var userPresets: [T]?
    
    init() {}
    
    required init?(_ map: NSDictionary) {
        
        self.state = map.enumValue(forKey: "state", ofType: EffectsUnitState.self)
        self.userPresets = map.arrayValue(forKey: "userPresets", ofType: T.self)
    }
}

class EffectsUnitPresetState: PersistentStateProtocol {
    
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
class AudioGraphState: PersistentStateProtocol {
    
    var outputDevice: AudioDeviceState?
    
    var volume: Float?
    var muted: Bool?
    var balance: Float?
    
    var masterUnit: MasterUnitState?
    var eqUnit: EQUnitState?
    var pitchUnit: PitchUnitState?
    var timeUnit: TimeUnitState?
    var reverbUnit: ReverbUnitState?
    var delayUnit: DelayUnitState?
    var filterUnit: FilterUnitState?
    var audioUnits: [AudioUnitState]?
    
    var soundProfiles: [SoundProfilePersistentState]?
    
    init() {}
    
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
