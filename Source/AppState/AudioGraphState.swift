import Foundation
import AVFoundation

class FXUnitState<T: EffectsUnitPreset> {
    
    var state: EffectsUnitState = .bypassed
    var userPresets: [T] = [T]()
}

class MasterUnitState: FXUnitState<MasterPreset>, PersistentState {
    
    static func deserialize(_ map: NSDictionary) -> MasterUnitState {
        
        let masterState = MasterUnitState()
        
        masterState.state = mapEnum(map, "state", AppDefaults.masterState)
        
        if let userPresets = map["userPresets"] as? [NSDictionary] {
            
            for presetDict in userPresets {
                
                let preset = deserializeMasterPreset(presetDict)
                if !StringUtils.isStringEmpty(preset.name) {    // Preset must have a name
                    masterState.userPresets.append(preset)
                }
            }
        }
        
        return masterState
    }
}

fileprivate func deserializeMasterPreset(_ map: NSDictionary) -> MasterPreset {
    
    let name = map["name"] as? String ?? ""
    
    // EQ preset
    var eqPreset: EQPreset = EQPresets.defaultPreset
    if let eqDict = map["eq"] as? NSDictionary {
        eqPreset = deserializeEQPreset(eqDict)
    }
    
    // Pitch preset
    var pitchPreset: PitchPreset = PitchPresets.defaultPreset
    if let pitchDict = map["pitch"] as? NSDictionary {
        pitchPreset = deserializePitchPreset(pitchDict)
    }
    
    // Time preset
    var timePreset: TimePreset = TimePresets.defaultPreset
    if let timeDict = map["time"] as? NSDictionary {
        timePreset = deserializeTimePreset(timeDict)
    }
    
    // Reverb preset
    var reverbPreset: ReverbPreset = ReverbPreset("", AppDefaults.reverbState, AppDefaults.reverbSpace, AppDefaults.reverbAmount, false)
    if let reverbDict = map["reverb"] as? NSDictionary {
        reverbPreset = deserializeReverbPreset(reverbDict)
    }
    
    // Delay preset
    var delayPreset: DelayPreset = DelayPresets.defaultPreset
    if let delayDict = map["delay"] as? NSDictionary {
        delayPreset = deserializeDelayPreset(delayDict)
    }
    
    // Filter preset
    var filterPreset: FilterPreset = FilterPresets.defaultPreset
    if let filterDict = map["filter"] as? NSDictionary {
        filterPreset = deserializeFilterPreset(filterDict)
    }
    
    var auPresets: [AudioUnitPreset] = []
    if let auPresetsArr = map["audioUnits"] as? [NSDictionary] {
        auPresets = auPresetsArr.map {deserializeAUPreset($0)}
    }
    
    return MasterPreset(name, eqPreset, pitchPreset, timePreset, reverbPreset, delayPreset, filterPreset, auPresets, false)
}

class EQUnitState: FXUnitState<EQPreset>, PersistentState {
    
    var type: EQType = AppDefaults.eqType
    var globalGain: Float = AppDefaults.eqGlobalGain
    var bands: [Float] = [Float]() // Index -> Gain
    
    static func deserialize(_ map: NSDictionary) -> EQUnitState {
        
        let eqState: EQUnitState = EQUnitState()
        
        eqState.state = mapEnum(map, "state", AppDefaults.eqState)
        eqState.type = mapEnum(map, "type", AppDefaults.eqType)
        eqState.globalGain = mapNumeric(map, "globalGain", AppDefaults.eqGlobalGain)
        
        if let bands: NSArray = map["bands"] as? NSArray {
            for gain in bands {eqState.bands.append((gain as? NSNumber)?.floatValue ?? AppDefaults.eqBandGain)}
        }
        
        // EQ User presets
        if let userPresets = map["userPresets"] as? [NSDictionary] {
            
            for presetDict in userPresets {
                
                let preset = deserializeEQPreset(presetDict)
                if !StringUtils.isStringEmpty(preset.name) {    // Preset must have a name
                    eqState.userPresets.append(preset)
                }
            }
        }
        
        return eqState
    }
}

fileprivate func deserializeEQPreset(_ map: NSDictionary) -> EQPreset {
    
    let name = map["name"] as? String ?? ""
    let state = mapEnum(map, "state", AppDefaults.eqState)
    let globalGain: Float = mapNumeric(map, "globalGain", AppDefaults.eqGlobalGain)
    var bands: [Float] = [Float]()
    
    if let eqBands: NSArray = map["bands"] as? NSArray {
        for gain in eqBands {bands.append((gain as? NSNumber)?.floatValue ?? AppDefaults.eqBandGain)}
    }
    
    return EQPreset(name, state, bands, globalGain, false)
}

class PitchUnitState: FXUnitState<PitchPreset>, PersistentState {
    
    var pitch: Float = AppDefaults.pitch
    var overlap: Float = AppDefaults.pitchOverlap
    
    static func deserialize(_ map: NSDictionary) -> PitchUnitState {
        
        let state: PitchUnitState = PitchUnitState()
        
        state.state = mapEnum(map, "state", AppDefaults.pitchState)
        state.pitch = mapNumeric(map, "pitch", AppDefaults.pitch)
        state.overlap = mapNumeric(map, "overlap", AppDefaults.pitchOverlap)
        
        // Pitch user presets
        if let userPresets = map["userPresets"] as? [NSDictionary] {
            
            for presetDict in userPresets {
                
                let preset = deserializePitchPreset(presetDict)
                if !StringUtils.isStringEmpty(preset.name) {    // Preset must have a name
                    state.userPresets.append(preset)
                }
            }
        }
        
        return state
    }
}

fileprivate func deserializePitchPreset(_ map: NSDictionary) -> PitchPreset {
    
    let name = map["name"] as? String ?? ""
    let state = mapEnum(map, "state", AppDefaults.pitchState)
    let pitch: Float = mapNumeric(map, "pitch", AppDefaults.pitch)
    let overlap: Float = mapNumeric(map, "overlap", AppDefaults.pitchOverlap)
    
    return PitchPreset(name, state, pitch, overlap, false)
}

class TimeUnitState: FXUnitState<TimePreset>, PersistentState {
    
    var rate: Float = AppDefaults.timeStretchRate
    var shiftPitch: Bool = AppDefaults.timeShiftPitch
    var overlap: Float = AppDefaults.timeOverlap
    
    static func deserialize(_ map: NSDictionary) -> TimeUnitState {
        
        let timeState: TimeUnitState = TimeUnitState()
        
        timeState.state = mapEnum(map, "state", AppDefaults.timeState)
        timeState.rate = mapNumeric(map, "rate", AppDefaults.timeStretchRate)
        timeState.overlap = mapNumeric(map, "overlap", AppDefaults.timeOverlap)
        timeState.shiftPitch = mapDirectly(map, "shiftPitch", AppDefaults.timeShiftPitch)
        
        // Time user presets
        if let userPresets = map["userPresets"] as? [NSDictionary] {
            
            for presetDict in userPresets {
                
                let preset = deserializeTimePreset(presetDict)
                if !StringUtils.isStringEmpty(preset.name) {    // Preset must have a name
                    timeState.userPresets.append(preset)
                }
            }
        }
        
        return timeState
    }
}

fileprivate func deserializeTimePreset(_ map: NSDictionary) -> TimePreset {
    
    let name = map["name"] as? String ?? ""
    let state = mapEnum(map, "state", AppDefaults.timeState)
    let rate: Float = mapNumeric(map, "rate", AppDefaults.timeStretchRate)
    let overlap: Float = mapNumeric(map, "overlap", AppDefaults.timeOverlap)
    let shiftPitch: Bool = mapDirectly(map, "shiftPitch", AppDefaults.timeShiftPitch)
    
    return TimePreset(name, state, rate, overlap, shiftPitch, false)
}

class ReverbUnitState: FXUnitState<ReverbPreset>, PersistentState {
    
    var space: ReverbSpaces = AppDefaults.reverbSpace
    var amount: Float = AppDefaults.reverbAmount
    
    static func deserialize(_ map: NSDictionary) -> ReverbUnitState {
        
        let reverbState: ReverbUnitState = ReverbUnitState()
        
        reverbState.state = mapEnum(map, "state", AppDefaults.reverbState)
        reverbState.space = mapEnum(map, "space", AppDefaults.reverbSpace)
        reverbState.amount = mapNumeric(map, "amount", AppDefaults.reverbAmount)
        
        // Reverb user presets
        if let userPresets = map["userPresets"] as? [NSDictionary] {
            
            for presetDict in userPresets {
                
                let preset = deserializeReverbPreset(presetDict)
                if !StringUtils.isStringEmpty(preset.name) {    // Preset must have a name
                    reverbState.userPresets.append(preset)
                }
            }
        }
        
        return reverbState
    }
}

fileprivate func deserializeReverbPreset(_ map: NSDictionary) -> ReverbPreset {
    
    let name = map["name"] as? String ?? ""
    let state = mapEnum(map, "state", AppDefaults.reverbState)
    let space: ReverbSpaces = mapEnum(map, "space", AppDefaults.reverbSpace)
    let amount: Float = mapNumeric(map, "amount", AppDefaults.reverbAmount)
    
    return ReverbPreset(name, state, space, amount, false)
}

class DelayUnitState: FXUnitState<DelayPreset>, PersistentState {
    
    var amount: Float = AppDefaults.delayAmount
    var time: Double = AppDefaults.delayTime
    var feedback: Float = AppDefaults.delayFeedback
    var lowPassCutoff: Float = AppDefaults.delayLowPassCutoff
    
    static func deserialize(_ map: NSDictionary) -> DelayUnitState {
        
        let delayState: DelayUnitState = DelayUnitState()
        
        delayState.state = mapEnum(map, "state", AppDefaults.delayState)
        delayState.amount = mapNumeric(map, "amount", AppDefaults.delayAmount)
        delayState.time = mapNumeric(map, "time", AppDefaults.delayTime)
        delayState.feedback = mapNumeric(map, "feedback", AppDefaults.delayFeedback)
        delayState.lowPassCutoff = mapNumeric(map, "lowPassCutoff", AppDefaults.delayLowPassCutoff)
        
        // Delay user presets
        if let userPresets = map["userPresets"] as? [NSDictionary] {
            
            for presetDict in userPresets {
                
                let preset = deserializeDelayPreset(presetDict)
                if !StringUtils.isStringEmpty(preset.name) {    // Preset must have a name
                    delayState.userPresets.append(preset)
                }
            }
        }
        
        return delayState
    }
}

fileprivate func deserializeDelayPreset(_ map: NSDictionary) -> DelayPreset {
    
    let name = map["name"] as? String ?? ""
    let state = mapEnum(map, "state", AppDefaults.delayState)
    
    let amount: Float = mapNumeric(map, "amount", AppDefaults.delayAmount)
    let time: Double = mapNumeric(map, "time", AppDefaults.delayTime)
    let feedback: Float = mapNumeric(map, "feedback", AppDefaults.delayFeedback)
    let cutoff: Float = mapNumeric(map, "lowPassCutoff", AppDefaults.delayLowPassCutoff)
    
    return DelayPreset(name, state, amount, time, feedback, cutoff, false)
}

class FilterUnitState: FXUnitState<FilterPreset>, PersistentState {
    
    var bands: [FilterBand] = []
    
    static func deserialize(_ map: NSDictionary) -> FilterUnitState {
        
        let filterState: FilterUnitState = FilterUnitState()
        
        filterState.state = mapEnum(map, "state", AppDefaults.filterState)
        
        if let bands = map["bands"] as? [NSDictionary] {
            
            for bandDict in bands {
                
                let bandType: FilterBandType = mapEnum(bandDict, "type", AppDefaults.filterBandType)
                let bandMinFreq: Float? = mapNumeric(bandDict, "minFreq")
                let bandMaxFreq: Float? = mapNumeric(bandDict, "maxFreq")
                
                filterState.bands.append(FilterBand(bandType, bandMinFreq, bandMaxFreq))
            }
        }
        
        // Filter user presets
        if let userPresets = map["userPresets"] as? [NSDictionary] {
            
            for presetDict in userPresets {
                
                let preset = deserializeFilterPreset(presetDict)
                if !StringUtils.isStringEmpty(preset.name) {    // Preset must have a name
                    filterState.userPresets.append(preset)
                }
            }
        }
        
        return filterState
    }
}

class AudioUnitState: FXUnitState<AudioUnitPreset>, PersistentState {
    
    var componentSubType: Int = 0
    var params: [AudioUnitParameterState] = []
    
    static func deserialize(_ map: NSDictionary) -> AudioUnitState {
        
        let auState: AudioUnitState = AudioUnitState()
        
        auState.state = mapEnum(map, "state", AppDefaults.auState)
        
        auState.componentSubType = (map["componentSubType"] as? NSNumber)?.intValue ?? 0
        
        if let paramsArr = map["params"] as? [NSDictionary] {
            auState.params = paramsArr.compactMap {AudioUnitParameterState.deserialize($0)}
        }
        
        // Audio units user presets
        if let userPresets = map["userPresets"] as? [NSDictionary] {
            
            for presetDict in userPresets {
                
                let preset = deserializeAUPreset(presetDict)
                if !StringUtils.isStringEmpty(preset.name) {    // Preset must have a name
                    auState.userPresets.append(preset)
                }
            }
        }
        
        return auState
    }
}

class AudioUnitParameterState: PersistentState {
    
    var address: UInt64 = 0
    var value: Float = 0
    
    static func deserialize(_ map: NSDictionary) -> AudioUnitParameterState {
        
        let state = AudioUnitParameterState()
     
        state.address = (map["address"] as? NSNumber)?.uint64Value ?? 0
        state.value = (map["value"] as? NSNumber)?.floatValue ?? 0
        
        return state
    }
}

fileprivate func deserializeFilterPreset(_ map: NSDictionary) -> FilterPreset {
    
    let name = map["name"] as? String ?? ""
    let state = mapEnum(map, "state", AppDefaults.filterState)
    
    var presetBands: [FilterBand] = []
    if let bands = map["bands"] as? [NSDictionary] {
        
        for bandDict in bands {
            
            let bandType: FilterBandType = mapEnum(bandDict, "type", AppDefaults.filterBandType)
            let bandMinFreq: Float? = mapNumeric(bandDict, "minFreq")
            let bandMaxFreq: Float? = mapNumeric(bandDict, "maxFreq")
            
            presetBands.append(FilterBand(bandType, bandMinFreq, bandMaxFreq))
        }
    }
    
    return FilterPreset(name, state, presetBands, false)
}

fileprivate func deserializeAUPreset(_ map: NSDictionary) -> AudioUnitPreset {
    
    let name = map["name"] as? String ?? ""
    let state = mapEnum(map, "state", AppDefaults.reverbState)
    
    let number: Int = (map["number"] as? NSNumber)?.intValue ?? 0
    
    return AudioUnitPreset(name, state, false, number: number)
}

/*
 Encapsulates audio graph state
 */
class AudioGraphState: PersistentState {
    
    var outputDevice: AudioDeviceState = AudioDeviceState()
    
    var volume: Float = AppDefaults.volume
    var muted: Bool = AppDefaults.muted
    var balance: Float = AppDefaults.balance
    
    var masterUnit: MasterUnitState = MasterUnitState()
    var eqUnit: EQUnitState = EQUnitState()
    var pitchUnit: PitchUnitState = PitchUnitState()
    var timeUnit: TimeUnitState = TimeUnitState()
    var reverbUnit: ReverbUnitState = ReverbUnitState()
    var delayUnit: DelayUnitState = DelayUnitState()
    var filterUnit: FilterUnitState = FilterUnitState()
    var audioUnits: [AudioUnitState] = []
    
    var soundProfiles: [SoundProfile] = []
    
    static func deserialize(_ map: NSDictionary) -> AudioGraphState {
        
        let audioGraphState = AudioGraphState()
        
        if let outputDeviceDict = (map["outputDevice"] as? NSDictionary) {
            audioGraphState.outputDevice = AudioDeviceState.deserialize(outputDeviceDict)
        }
        
        audioGraphState.volume = mapNumeric(map, "volume", AppDefaults.volume)
        audioGraphState.muted = mapDirectly(map, "muted", AppDefaults.muted)
        audioGraphState.balance = mapNumeric(map, "balance", AppDefaults.balance)
        
        if let masterDict = (map["masterUnit"] as? NSDictionary) {
            audioGraphState.masterUnit = MasterUnitState.deserialize(masterDict)
        }
        
        if let eqDict = (map["eqUnit"] as? NSDictionary) {
            audioGraphState.eqUnit = EQUnitState.deserialize(eqDict)
        }
        
        if let pitchDict = (map["pitchUnit"] as? NSDictionary) {
            audioGraphState.pitchUnit = PitchUnitState.deserialize(pitchDict)
        }
        
        if let timeDict = (map["timeUnit"] as? NSDictionary) {
            audioGraphState.timeUnit = TimeUnitState.deserialize(timeDict)
        }
        
        if let reverbDict = (map["reverbUnit"] as? NSDictionary) {
            audioGraphState.reverbUnit = ReverbUnitState.deserialize(reverbDict)
        }
        
        if let delayDict = (map["delayUnit"] as? NSDictionary) {
            audioGraphState.delayUnit = DelayUnitState.deserialize(delayDict)
        }
        
        if let filterDict = (map["filterUnit"] as? NSDictionary) {
            audioGraphState.filterUnit = FilterUnitState.deserialize(filterDict)
        }
        
        if let auDictsArr = map["audioUnits"] as? [NSDictionary] {
            audioGraphState.audioUnits = auDictsArr.map {AudioUnitState.deserialize($0)}
        }
        
        if let profilesArr = map["soundProfiles"] as? [NSDictionary] {
            
            for profileDict in profilesArr {
                
                if let filePath = profileDict["file"] as? String {
                    
                    let profileVolume: Float = mapNumeric(profileDict, "volume", AppDefaults.volume)
                    let profileBalance: Float = mapNumeric(profileDict, "balance", AppDefaults.balance)
                    
                    if let effectsDict = profileDict["effects"] as? NSDictionary {
                        
                        let effects = deserializeMasterPreset(effectsDict)
                        audioGraphState.soundProfiles.append(SoundProfile(file: URL(fileURLWithPath: filePath), volume: profileVolume, balance: profileBalance, effects: effects))
                    }
                }
            }
        }
        
        return audioGraphState
    }
}
