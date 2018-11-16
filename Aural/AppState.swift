import Cocoa

// Marks an object as having state that needs to be persisted
protocol PersistentModelObject {
    
    // Retrieves persistent state for this model object
    func persistentState() -> PersistentState
}

// Marks an object as being suitable for persistence, i.e. it is serializable/deserializable
protocol PersistentState {
    
    // Constructs an instance of this state object from the given map
    static func deserialize(_ map: NSDictionary) -> PersistentState
}

/*
    Encapsulates UI state
 */
class UIState: PersistentState {
    
    var windowLayout: WindowLayoutState = WindowLayoutState()
    var player: PlayerState = PlayerState()
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = UIState()
        
        if let windowLayoutMap = map["windowLayout"] as? NSDictionary {
            state.windowLayout = WindowLayoutState.deserialize(windowLayoutMap) as! WindowLayoutState
        }
        
        if let playerMap = map["player"] as? NSDictionary {
            state.player = PlayerState.deserialize(playerMap) as! PlayerState
        }
        
        return state
    }
}

class PlayerState: PersistentState {
    
    var viewType: PlayerViewType = .defaultView
    
    var showAlbumArt: Bool = true
    var showTrackInfo: Bool = true
    var showSequenceInfo: Bool = true
    var showPlayingTrackFunctions: Bool = true
    var showControls: Bool = true
    var showTimeElapsedRemaining: Bool = true
    
    var timeElapsedDisplayType: TimeElapsedDisplayType = .formatted
    var timeRemainingDisplayType: TimeRemainingDisplayType = .formatted
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = PlayerState()
        
        state.viewType = mapEnum(map, "viewType", PlayerViewType.defaultView)
        
        state.showAlbumArt = mapDirectly(map, "showAlbumArt", true)
        state.showTrackInfo = mapDirectly(map, "showTrackInfo", true)
        state.showSequenceInfo = mapDirectly(map, "showSequenceInfo", true)
        state.showControls = mapDirectly(map, "showControls", true)
        state.showTimeElapsedRemaining = mapDirectly(map, "showTimeElapsedRemaining", true)
        state.showPlayingTrackFunctions = mapDirectly(map, "showPlayingTrackFunctions", true)
        
        state.timeElapsedDisplayType = mapEnum(map, "timeElapsedDisplayType", TimeElapsedDisplayType.formatted)
        state.timeRemainingDisplayType = mapEnum(map, "timeRemainingDisplayType", TimeRemainingDisplayType.formatted)
        
        return state
    }
}

fileprivate func mapEnum<T: RawRepresentable>(_ map: NSDictionary, _ key: String, _ defaultValue: T) -> T where T.RawValue == String {
    if let rawVal = map[key] as? String, let enumVal = T.self.init(rawValue: rawVal) {return enumVal} else {return defaultValue}
}

fileprivate func mapBool(_ map: NSDictionary, _ key: String, _ defaultValue: Bool) -> Bool {
    if let value = map[key] as? Bool {return value} else {return defaultValue}
}

fileprivate func mapDirectly<T: Any>(_ map: NSDictionary, _ key: String, _ defaultValue: T) -> T {
    if let value = map[key] as? T {return value} else {return defaultValue}
}

fileprivate func mapNumeric<T: Any>(_ map: NSDictionary, _ key: String, _ defaultValue: T) -> T {
    
    if let value = map[key] as? NSNumber {
        return doMapNumeric(value, T.self)
    }
    
    return defaultValue
}

fileprivate func doMapNumeric<T: Any>(_ value: NSNumber, _ type: T.Type) -> T {
    
    switch String(describing: type) {
        
    case "Float", "CGFloat": return value.floatValue as! T
        
    case "Double": return value.doubleValue as! T
        
    case "Int": return value.intValue as! T
        
    // Should not happen
    default: return value.doubleValue as! T
        
    }
}

// Allows optional values
fileprivate func mapNumeric<T: Any>(_ map: NSDictionary, _ key: String) -> T? {
    
    if let value = map[key] as? NSNumber {
        return doMapNumeric(value, T.self)
    }
    
    return nil
}

class WindowLayoutState: PersistentState {
    
    var showEffects: Bool = true
    var showPlaylist: Bool = true

    var mainWindowOrigin: NSPoint = NSPoint.zero
    var effectsWindowOrigin: NSPoint? = nil
    var playlistWindowFrame: NSRect? = nil
    
    var userLayouts: [WindowLayout] = [WindowLayout]()
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = WindowLayoutState()
        
        state.showPlaylist = mapDirectly(map, "showPlaylist", true)
        state.showEffects = mapDirectly(map, "showEffects", true)
        
        if let mainWindowOriginDict = map["mainWindowOrigin"] as? NSDictionary, let origin = mapNSPoint(mainWindowOriginDict) {
            state.mainWindowOrigin = origin
        }
        
        if let effectsWindowOriginDict = map["effectsWindowOrigin"] as? NSDictionary, let origin = mapNSPoint(effectsWindowOriginDict) {
            state.effectsWindowOrigin = origin
        }
        
        if let frameDict = map["playlistWindowFrame"] as? NSDictionary, let originDict = frameDict["origin"] as? NSDictionary, let origin = mapNSPoint(originDict), let sizeDict = frameDict["size"] as? NSDictionary, let size = mapNSSize(sizeDict) {
            
            state.playlistWindowFrame = NSRect(origin: origin, size: size)
        }
        
        if let userLayouts = map["userLayouts"] as? [NSDictionary] {
            
            for layout in userLayouts {
                
                var layoutName: String?
                
                var layoutShowEffects: Bool?
                var layoutShowPlaylist: Bool?
                
                var layoutMainWindowOrigin: NSPoint?
                var layoutEffectsWindowOrigin: NSPoint?
                var layoutPlaylistWindowFrame: NSRect?
                
                if let name = layout["name"] as? String {
                    layoutName = name
                }
                
                // TODO: These are optional. Write a new helper function mapOptionalVal which may return nil
                layoutShowPlaylist = mapDirectly(layout, "showPlaylist", true)
                layoutShowEffects = mapDirectly(layout, "showEffects", true)
                
                if let mainWindowOriginDict = layout["mainWindowOrigin"] as? NSDictionary, let origin = mapNSPoint(mainWindowOriginDict) {
                    layoutMainWindowOrigin = origin
                }
                
                if let effectsWindowOriginDict = layout["effectsWindowOrigin"] as? NSDictionary, let origin = mapNSPoint(effectsWindowOriginDict) {
                    layoutEffectsWindowOrigin = origin
                }
                
                if let frameDict = layout["playlistWindowFrame"] as? NSDictionary, let originDict = frameDict["origin"] as? NSDictionary, let origin = mapNSPoint(originDict), let sizeDict = frameDict["size"] as? NSDictionary, let size = mapNSSize(sizeDict) {
                    
                    layoutPlaylistWindowFrame = NSRect(origin: origin, size: size)
                }
                
                // Make sure you have all the required info
                if layoutName != nil && layoutShowEffects != nil && layoutShowPlaylist != nil && layoutMainWindowOrigin != nil {
                    
                    if ((layoutShowEffects! && layoutEffectsWindowOrigin != nil) || !layoutShowEffects!) {
                        
                        if ((layoutShowPlaylist! && layoutPlaylistWindowFrame != nil) || !layoutShowPlaylist!) {
                            
                            let newLayout = WindowLayout(layoutName!, layoutShowEffects!, layoutShowPlaylist!, layoutMainWindowOrigin!, layoutEffectsWindowOrigin, layoutPlaylistWindowFrame, false)
                            newLayout.name = ""
                            
                            state.userLayouts.append(newLayout)
                        }
                    }
                }
            }
        }
        
        return state
    }
}

fileprivate func mapNSPoint(_ map: NSDictionary) -> NSPoint? {
    
    if let px = map["x"] as? NSNumber, let py = map["y"] as? NSNumber {
        return NSPoint(x: CGFloat(px.floatValue), y: CGFloat(py.floatValue))
    }
    
    return nil
}

fileprivate func mapNSSize(_ map: NSDictionary) -> NSSize? {
    
    if let wd = map["width"] as? NSNumber, let ht = map["height"] as? NSNumber {
        return NSSize(width: CGFloat(wd.floatValue), height: CGFloat(ht.floatValue))
    }
    
    return nil
}

class FXUnitState<T: EffectsUnitPreset> {
    
    var state: EffectsUnitState = .bypassed
    var userPresets: [T] = [T]()
}

class MasterUnitState: FXUnitState<MasterPreset>, PersistentState {
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let masterState = MasterUnitState()
        
        if let stateStr = map["state"] as? String, let state = EffectsUnitState(rawValue: stateStr) {
            masterState.state = state
        }
        
        if let userPresets = map["userPresets"] as? [NSDictionary] {
            
            userPresets.forEach({
                
                if let presetName = $0["name"] as? String {
                    
                    // EQ preset
                    var eqPreset: EQPreset = EQPresets.defaultPreset
                    if let eqDict = $0["eq"] as? NSDictionary {
                        
                        let eqPresetState: EffectsUnitState = mapEnum(eqDict, "state", AppDefaults.eqState)
                        let eqPresetGlobalGain: Float = mapNumeric(eqDict, "globalGain", AppDefaults.eqGlobalGain)
                        var eqPresetBands: [Float] = [Float]()
                        
                        if let eqBands: NSArray = eqDict["bands"] as? NSArray {
                            for gain in eqBands {eqPresetBands.append((gain as? NSNumber)?.floatValue ?? AppDefaults.eqBandGain)}
                        }
                        
                        eqPreset = EQPreset("", eqPresetState, eqPresetBands, eqPresetGlobalGain, false)
                    }
                    
                    // Pitch preset
                    var pitchPreset: PitchPreset = PitchPresets.defaultPreset
                    if let pitchDict = $0["pitch"] as? NSDictionary {
                        
                        let pitchPresetState: EffectsUnitState = mapEnum(pitchDict, "state", AppDefaults.pitchState)
                        let pitchPresetPitch: Float = mapNumeric(pitchDict, "pitch", AppDefaults.pitch)
                        let pitchPresetOverlap: Float = mapNumeric(pitchDict, "overlap", AppDefaults.pitchOverlap)
                        
                        pitchPreset = PitchPreset("", pitchPresetState, pitchPresetPitch, pitchPresetOverlap, false)
                    }
                    
                    // Time preset
                    var timePreset: TimePreset = TimePresets.defaultPreset
                    if let timeDict = $0["time"] as? NSDictionary {
                        
                        let timePresetState: EffectsUnitState = mapEnum(timeDict, "state", AppDefaults.timeState)
                        let timePresetRate: Float = mapNumeric(timeDict, "rate", AppDefaults.timeStretchRate)
                        let timePresetOverlap: Float = mapNumeric(timeDict, "overlap", AppDefaults.timeOverlap)
                        let timePresetPitchShift: Bool = mapDirectly(timeDict, "shiftPitch", AppDefaults.timeShiftPitch)
                        
                        timePreset = TimePreset("", timePresetState, timePresetRate, timePresetOverlap, timePresetPitchShift, false)
                    }
                    
                    // Reverb preset
                    var reverbPreset: ReverbPreset = ReverbPreset("", AppDefaults.reverbState, AppDefaults.reverbSpace, AppDefaults.reverbAmount, false)
                    if let reverbDict = $0["reverb"] as? NSDictionary {
                        
                        let reverbPresetState: EffectsUnitState = mapEnum(reverbDict, "state", AppDefaults.reverbState)
                        let reverbPresetSpace: ReverbSpaces = mapEnum(reverbDict, "space", AppDefaults.reverbSpace)
                        let reverbPresetAmount: Float = mapNumeric(reverbDict, "amount", AppDefaults.reverbAmount)
                        
                        reverbPreset = ReverbPreset("", reverbPresetState, reverbPresetSpace, reverbPresetAmount, false)
                    }
                    
                    // Delay preset
                    var delayPreset: DelayPreset = DelayPresets.defaultPreset
                    if let delayDict = $0["delay"] as? NSDictionary {
                        
                        let delayPresetState: EffectsUnitState = mapEnum(delayDict, "state", AppDefaults.delayState)
                        let delayPresetAmount: Float = mapNumeric(delayDict, "amount", AppDefaults.delayAmount)
                        let delayPresetTime: Double = mapNumeric(delayDict, "time", AppDefaults.delayTime)
                        let delayPresetFeedback: Float = mapNumeric(delayDict, "feedback", AppDefaults.delayFeedback)
                        let delayPresetCutoff: Float = mapNumeric(delayDict, "lowPassCutoff", AppDefaults.delayLowPassCutoff)
                        
                        delayPreset = DelayPreset("", delayPresetState, delayPresetAmount, delayPresetTime, delayPresetFeedback, delayPresetCutoff, false)
                    }
                    
                    // Filter preset
                    var filterPreset: FilterPreset = FilterPresets.defaultPreset
                    if let filterDict = $0["filter"] as? NSDictionary {
                        
                        let filterPresetState: EffectsUnitState = mapEnum(filterDict, "state", AppDefaults.filterState)
                        var presetBands: [FilterBand] = []
                        
                        if let bands = filterDict["bands"] as? [NSDictionary] {
                            
                            for band in bands {
                                
                                let bandType: FilterBandType = mapEnum(band, "type", AppDefaults.filterBandType)
                                let bandMinFreq: Float? = mapNumeric(band, "minFreq")
                                let bandMaxFreq: Float? = mapNumeric(band, "maxFreq")
                                
                                presetBands.append(FilterBand(bandType, bandMinFreq, bandMaxFreq))
                            }
                        }
                        
                        filterPreset = FilterPreset("", filterPresetState, presetBands, false)
                    }
                    
                    masterState.userPresets.append(MasterPreset(presetName, eqPreset, pitchPreset, timePreset, reverbPreset, delayPreset, filterPreset, false))
                }
            })
        }
        
        return masterState
    }
}

class EQUnitState: FXUnitState<EQPreset>, PersistentState {
    
    var type: EQType = AppDefaults.eqType
    var globalGain: Float = AppDefaults.eqGlobalGain
    var bands: [Float] = [Float]() // Index -> Gain
    var sync: Bool = AppDefaults.eqSync

    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let eqState: EQUnitState = EQUnitState()
        
        eqState.state = mapEnum(map, "state", AppDefaults.eqState)
        eqState.type = mapEnum(map, "type", AppDefaults.eqType)
        eqState.sync = mapDirectly(map, "sync", AppDefaults.eqSync)
        eqState.globalGain = mapNumeric(map, "globalGain", AppDefaults.eqGlobalGain)
        
        if let bands: NSArray = map["bands"] as? NSArray {
            for gain in bands {eqState.bands.append((gain as? NSNumber)?.floatValue ?? AppDefaults.eqBandGain)}
        }
        
        // EQ User presets
        if let userPresets = map["userPresets"] as? [NSDictionary] {
            
            for presetDict in userPresets {
                
                // Preset must have a name
                if let presetName = presetDict["name"] as? String {
                    
                    let eqPresetGlobalGain: Float = mapNumeric(presetDict, "globalGain", AppDefaults.eqGlobalGain)
                    var eqPresetBands: [Float] = [Float]()
                    
                    if let eqBands: NSArray = presetDict["bands"] as? NSArray {
                        for gain in eqBands {eqPresetBands.append((gain as? NSNumber)?.floatValue ?? AppDefaults.eqBandGain)}
                    }
                    
                    eqState.userPresets.append(EQPreset(presetName, .active, eqPresetBands, eqPresetGlobalGain, false))
                }
            }
        }
        
        return eqState
    }
}

class PitchUnitState: FXUnitState<PitchPreset>, PersistentState {
    
    var pitch: Float = AppDefaults.pitch
    var overlap: Float = AppDefaults.pitchOverlap
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state: PitchUnitState = PitchUnitState()
        
        state.state = mapEnum(map, "state", AppDefaults.pitchState)
        state.pitch = mapNumeric(map, "pitch", AppDefaults.pitch)
        state.overlap = mapNumeric(map, "overlap", AppDefaults.pitchOverlap)
        
        // Pitch user presets
        if let userPresets = map["userPresets"] as? [NSDictionary] {
            
            for presetDict in userPresets {
                
                // Preset must have a name
                if let presetName = presetDict["name"] as? String {
                    
                    let pitchPresetPitch: Float = mapNumeric(presetDict, "pitch", AppDefaults.pitch)
                    let pitchPresetOverlap: Float = mapNumeric(presetDict, "overlap", AppDefaults.pitchOverlap)
                    
                    state.userPresets.append(PitchPreset(presetName, .active, pitchPresetPitch, pitchPresetOverlap, false))
                }
            }
        }
        
        return state
    }
}

class TimeUnitState: FXUnitState<TimePreset>, PersistentState {
    
    var rate: Float = AppDefaults.timeStretchRate
    var shiftPitch: Bool = AppDefaults.timeShiftPitch
    var overlap: Float = AppDefaults.timeOverlap
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let timeState: TimeUnitState = TimeUnitState()
        
        timeState.state = mapEnum(map, "state", AppDefaults.pitchState)
        timeState.rate = mapNumeric(map, "rate", AppDefaults.timeStretchRate)
        timeState.overlap = mapNumeric(map, "overlap", AppDefaults.timeOverlap)
        timeState.shiftPitch = mapDirectly(map, "shiftPitch", AppDefaults.timeShiftPitch)
        
        // Time user presets
        if let userPresets = map["userPresets"] as? [NSDictionary] {
            
            for presetDict in userPresets {
                
                // Preset must have a name
                if let presetName = presetDict["name"] as? String {
                    
                    let timePresetRate: Float = mapNumeric(presetDict, "rate", AppDefaults.timeStretchRate)
                    let timePresetOverlap: Float = mapNumeric(presetDict, "overlap", AppDefaults.timeOverlap)
                    let timePresetPitchShift: Bool = mapDirectly(presetDict, "shiftPitch", AppDefaults.timeShiftPitch)
                    
                    timeState.userPresets.append(TimePreset(presetName, .active, timePresetRate, timePresetOverlap, timePresetPitchShift, false))
                }
            }
        }
        
        return timeState
    }
}

class ReverbUnitState: FXUnitState<ReverbPreset>, PersistentState {
    
    var space: ReverbSpaces = AppDefaults.reverbSpace
    var amount: Float = AppDefaults.reverbAmount
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let reverbState: ReverbUnitState = ReverbUnitState()
        
        reverbState.state = mapEnum(map, "state", AppDefaults.reverbState)
        reverbState.space = mapEnum(map, "space", AppDefaults.reverbSpace)
        reverbState.amount = mapNumeric(map, "amount", AppDefaults.reverbAmount)
        
        // Reverb user presets
        if let userPresets = map["userPresets"] as? [NSDictionary] {
            
            for presetDict in userPresets {
                
                // Preset must have a name
                if let presetName = presetDict["name"] as? String {
                
                    let reverbPresetSpace: ReverbSpaces = mapEnum(presetDict, "space", AppDefaults.reverbSpace)
                    let reverbPresetAmount: Float = mapNumeric(presetDict, "amount", AppDefaults.reverbAmount)
                    
                    reverbState.userPresets.append(ReverbPreset(presetName, .active, reverbPresetSpace, reverbPresetAmount, false))
                }
            }
        }
        
        return reverbState
    }
}

class DelayUnitState: FXUnitState<DelayPreset>, PersistentState {
    
    var amount: Float = AppDefaults.delayAmount
    var time: Double = AppDefaults.delayTime
    var feedback: Float = AppDefaults.delayFeedback
    var lowPassCutoff: Float = AppDefaults.delayLowPassCutoff
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let delayState: DelayUnitState = DelayUnitState()
        
        delayState.state = mapEnum(map, "state", AppDefaults.delayState)
        delayState.amount = mapNumeric(map, "amount", AppDefaults.delayAmount)
        delayState.time = mapNumeric(map, "time", AppDefaults.delayTime)
        delayState.feedback = mapNumeric(map, "feedback", AppDefaults.delayFeedback)
        delayState.lowPassCutoff = mapNumeric(map, "lowPassCutoff", AppDefaults.delayLowPassCutoff)
        
        // Delay user presets
        if let userPresets = map["userPresets"] as? [NSDictionary] {
            
            for presetDict in userPresets {
                
                // Preset must have a name
                if let presetName = presetDict["name"] as? String {
                    
                    let delayPresetAmount: Float = mapNumeric(presetDict, "amount", AppDefaults.delayAmount)
                    let delayPresetTime: Double = mapNumeric(presetDict, "time", AppDefaults.delayTime)
                    let delayPresetFeedback: Float = mapNumeric(presetDict, "feedback", AppDefaults.delayFeedback)
                    let delayPresetCutoff: Float = mapNumeric(presetDict, "lowPassCutoff", AppDefaults.delayLowPassCutoff)
                    
                    delayState.userPresets.append(DelayPreset(presetName, .active, delayPresetAmount, delayPresetTime, delayPresetFeedback, delayPresetCutoff, false))
                }
            }
        }
        
        return delayState
    }
}

class FilterUnitState: FXUnitState<FilterPreset>, PersistentState {
    
    var bands: [FilterBand] = []
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let filterState: FilterUnitState = FilterUnitState()
        
        filterState.state = mapEnum(map, "state", AppDefaults.filterState)
        
        if let bands = map["bands"] as? [NSDictionary] {
            
            for band in bands {
                
                let bandType: FilterBandType = mapEnum(band, "type", AppDefaults.filterBandType)
                let bandMinFreq: Float? = mapNumeric(band, "minFreq")
                let bandMaxFreq: Float? = mapNumeric(band, "maxFreq")
                
                filterState.bands.append(FilterBand(bandType, bandMinFreq, bandMaxFreq))
            }
        }
        
        // Filter user presets
        if let userPresets = map["userPresets"] as? [NSDictionary] {
            
            for presetDict in userPresets {
                
                // Preset must have a name
                if let presetName = presetDict["name"] as? String {
                    
                    var presetBands: [FilterBand] = []
                    if let bands = presetDict["bands"] as? [NSDictionary] {
                        
                        for band in bands {
                            
                            let bandType: FilterBandType = mapEnum(band, "type", AppDefaults.filterBandType)
                            let bandMinFreq: Float? = mapNumeric(band, "minFreq")
                            let bandMaxFreq: Float? = mapNumeric(band, "maxFreq")
                            
                            presetBands.append(FilterBand(bandType, bandMinFreq, bandMaxFreq))
                        }
                    }
                    
                    filterState.userPresets.append(FilterPreset(presetName, .active, presetBands, false))
                }
            }
        }
        
        return filterState
    }
}

/*
    Encapsulates audio graph state
 */
class AudioGraphState: PersistentState {
    
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
    
    var soundProfiles: [SoundProfile] = []
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let audioGraphState = AudioGraphState()
        
        audioGraphState.volume = mapNumeric(map, "volume", AppDefaults.volume)
        audioGraphState.muted = mapDirectly(map, "muted", AppDefaults.muted)
        audioGraphState.balance = mapNumeric(map, "balance", AppDefaults.balance)
        
        if let masterDict = (map["masterUnit"] as? NSDictionary) {
            audioGraphState.masterUnit = MasterUnitState.deserialize(masterDict) as! MasterUnitState
        }
        
        if let eqDict = (map["eqUnit"] as? NSDictionary) {
            audioGraphState.eqUnit = EQUnitState.deserialize(eqDict) as! EQUnitState
        }
        
        if let pitchDict = (map["pitchUnit"] as? NSDictionary) {
            audioGraphState.pitchUnit = PitchUnitState.deserialize(pitchDict) as! PitchUnitState
        }
        
        if let timeDict = (map["timeUnit"] as? NSDictionary) {
            audioGraphState.timeUnit = TimeUnitState.deserialize(timeDict) as! TimeUnitState
        }
        
        if let reverbDict = (map["reverbUnit"] as? NSDictionary) {
            audioGraphState.reverbUnit = ReverbUnitState.deserialize(reverbDict) as! ReverbUnitState
        }
        
        if let delayDict = (map["delayUnit"] as? NSDictionary) {
            audioGraphState.delayUnit = DelayUnitState.deserialize(delayDict) as! DelayUnitState
        }
        
        if let filterDict = (map["filterUnit"] as? NSDictionary) {
            audioGraphState.filterUnit = FilterUnitState.deserialize(filterDict) as! FilterUnitState
        }
        
        if let profilesArr = map["soundProfiles"] as? [NSDictionary] {
            
            for profileDict in profilesArr {
                
                if let filePath = profileDict["file"] as? String {
                    
                    let profileVolume: Float = mapNumeric(profileDict, "volume", AppDefaults.volume)
                    let profileBalance: Float = mapNumeric(profileDict, "balance", AppDefaults.balance)
                    
                    if let effectsDict = (profileDict["effects"] as? NSDictionary) {
                        
                        // EQ preset
                        var eqPreset: EQPreset = EQPresets.defaultPreset
                        if let eqDict = effectsDict["eq"] as? NSDictionary {
                            
                            let eqPresetState: EffectsUnitState = mapEnum(eqDict, "state", AppDefaults.eqState)
                            let eqPresetGlobalGain: Float = mapNumeric(eqDict, "globalGain", AppDefaults.eqGlobalGain)
                            var eqPresetBands: [Float] = [Float]()
                            
                            if let eqBands: NSArray = eqDict["bands"] as? NSArray {
                                for gain in eqBands {eqPresetBands.append((gain as? NSNumber)?.floatValue ?? AppDefaults.eqBandGain)}
                            }
                            
                            eqPreset = EQPreset("", eqPresetState, eqPresetBands, eqPresetGlobalGain, false)
                        }
                        
                        // Pitch preset
                        var pitchPreset: PitchPreset = PitchPresets.defaultPreset
                        if let pitchDict = effectsDict["pitch"] as? NSDictionary {
                            
                            let pitchPresetState: EffectsUnitState = mapEnum(pitchDict, "state", AppDefaults.pitchState)
                            let pitchPresetPitch: Float = mapNumeric(pitchDict, "pitch", AppDefaults.pitch)
                            let pitchPresetOverlap: Float = mapNumeric(pitchDict, "overlap", AppDefaults.pitchOverlap)
                            
                            pitchPreset = PitchPreset("", pitchPresetState, pitchPresetPitch, pitchPresetOverlap, false)
                        }
                        
                        // Time preset
                        var timePreset: TimePreset = TimePresets.defaultPreset
                        if let timeDict = effectsDict["time"] as? NSDictionary {
                            
                            let timePresetState: EffectsUnitState = mapEnum(timeDict, "state", AppDefaults.timeState)
                            let timePresetRate: Float = mapNumeric(timeDict, "rate", AppDefaults.timeStretchRate)
                            let timePresetOverlap: Float = mapNumeric(timeDict, "overlap", AppDefaults.timeOverlap)
                            let timePresetPitchShift: Bool = mapDirectly(timeDict, "shiftPitch", AppDefaults.timeShiftPitch)
                            
                            timePreset = TimePreset("", timePresetState, timePresetRate, timePresetOverlap, timePresetPitchShift, false)
                        }
                        
                        // Reverb preset
                        var reverbPreset: ReverbPreset = ReverbPreset("", AppDefaults.reverbState, AppDefaults.reverbSpace, AppDefaults.reverbAmount, false)
                        if let reverbDict = effectsDict["reverb"] as? NSDictionary {
                            
                            let reverbPresetState: EffectsUnitState = mapEnum(reverbDict, "state", AppDefaults.reverbState)
                            let reverbPresetSpace: ReverbSpaces = mapEnum(reverbDict, "space", AppDefaults.reverbSpace)
                            let reverbPresetAmount: Float = mapNumeric(reverbDict, "amount", AppDefaults.reverbAmount)
                            
                            reverbPreset = ReverbPreset("", reverbPresetState, reverbPresetSpace, reverbPresetAmount, false)
                        }
                        
                        // Delay preset
                        var delayPreset: DelayPreset = DelayPresets.defaultPreset
                        if let delayDict = effectsDict["delay"] as? NSDictionary {
                            
                            let delayPresetState: EffectsUnitState = mapEnum(delayDict, "state", AppDefaults.delayState)
                            let delayPresetAmount: Float = mapNumeric(delayDict, "amount", AppDefaults.delayAmount)
                            let delayPresetTime: Double = mapNumeric(delayDict, "time", AppDefaults.delayTime)
                            let delayPresetFeedback: Float = mapNumeric(delayDict, "feedback", AppDefaults.delayFeedback)
                            let delayPresetCutoff: Float = mapNumeric(delayDict, "lowPassCutoff", AppDefaults.delayLowPassCutoff)
                            
                            delayPreset = DelayPreset("", delayPresetState, delayPresetAmount, delayPresetTime, delayPresetFeedback, delayPresetCutoff, false)
                        }
                        
                        // Filter preset
                        var filterPreset: FilterPreset = FilterPresets.defaultPreset
                        if let filterDict = effectsDict["filter"] as? NSDictionary {
                            
                            let filterPresetState: EffectsUnitState = mapEnum(filterDict, "state", AppDefaults.filterState)
                            var presetBands: [FilterBand] = []
                            
                            if let bands = filterDict["bands"] as? [NSDictionary] {
                                
                                for band in bands {
                                    
                                    let bandType: FilterBandType = mapEnum(band, "type", AppDefaults.filterBandType)
                                    let bandMinFreq: Float? = mapNumeric(band, "minFreq")
                                    let bandMaxFreq: Float? = mapNumeric(band, "maxFreq")
                                    
                                    presetBands.append(FilterBand(bandType, bandMinFreq, bandMaxFreq))
                                }
                            }
                            
                            filterPreset = FilterPreset("", filterPresetState, presetBands, false)
                        }
                        
                        let effects = MasterPreset("masterPreset_for_soundProfile", eqPreset, pitchPreset, timePreset, reverbPreset, delayPreset, filterPreset, false)
                        audioGraphState.soundProfiles.append(SoundProfile(file: URL(fileURLWithPath: filePath), volume: profileVolume, balance: profileBalance, effects: effects))
                    }
                }
            }
        }
        
        return audioGraphState
    }
}

/*
    Encapsulates playlist state
 */
class PlaylistState: PersistentState {
    
    // List of track files
    var tracks: [URL] = [URL]()
    var gaps: [PlaybackGapState] = []
    
    private var _transient_gapsBeforeMap: [URL: PlaybackGapState] = [:]
    private var _transient_gapsAfterMap: [URL: PlaybackGapState] = [:]
    
    func getGapsForTrack(_ track: Track) -> (gapBeforeTrack: PlaybackGapState?, gapAfterTrack: PlaybackGapState?) {
        return (_transient_gapsBeforeMap[track.file], _transient_gapsAfterMap[track.file])
    }
    
    func removeGapsForTrack(_ track: Track) {
        _transient_gapsBeforeMap.removeValue(forKey: track.file)
        _transient_gapsAfterMap.removeValue(forKey: track.file)
    }
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = PlaylistState()
        
        if let tracks = map["tracks"] as? [String] {
            tracks.forEach({state.tracks.append(URL(fileURLWithPath: $0))})
        }
        
        if let gaps = map["gaps"] as? [NSDictionary] {
            
            gaps.forEach({
                
                let gap = PlaybackGapState.deserialize($0) as! PlaybackGapState
                
                if gap.position == .beforeTrack {
                    state._transient_gapsBeforeMap[gap.track!] = gap
                } else {
                    state._transient_gapsAfterMap[gap.track!] = gap
                }
                
                state.gaps.append(gap)
            })
        }
        
        return state
    }
}

class PlaybackGapState: PersistentState {
    
    var track: URL?
    
    var duration: Double = AppDefaults.playbackGapDuration
    var position: PlaybackGapPosition = AppDefaults.playbackGapPosition
    var type: PlaybackGapType = AppDefaults.playbackGapType
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = PlaybackGapState()
        
        if let trackStr = map["track"] as? String {
            state.track = URL(fileURLWithPath: trackStr)
        }
        
        if let duration = map["duration"] as? NSNumber {
            state.duration = duration.doubleValue
        }
        
        if let positionStr = map["position"] as? String {
            
            if let position = PlaybackGapPosition(rawValue: positionStr) {
                state.position = position
            }
        }
        
        if let typeStr = map["type"] as? String {
            
            if let type = PlaybackGapType(rawValue: typeStr) {
                state.type = type
            }
        }
        
        return state
    }
}

/*
 Encapsulates playback sequence state
 */
class PlaybackSequenceState: PersistentState {
    
    var repeatMode: RepeatMode = AppDefaults.repeatMode
    var shuffleMode: ShuffleMode = AppDefaults.shuffleMode
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = PlaybackSequenceState()
        
        if let repeatModeStr = map["repeatMode"] as? String {
            if let repeatMode = RepeatMode(rawValue: repeatModeStr) {
                state.repeatMode = repeatMode
            }
        }
        
        if let shuffleModeStr = map["shuffleMode"] as? String {
            if let shuffleMode = ShuffleMode(rawValue: shuffleModeStr) {
                state.shuffleMode = shuffleMode
            }
        }
        
        return state
    }
}

class HistoryState: PersistentState {
    
    var recentlyAdded: [(file: URL, time: Date)] = [(file: URL, time: Date)]()
    var recentlyPlayed: [(file: URL, time: Date)] = [(file: URL, time: Date)]()
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = HistoryState()
        
        if let recentlyAdded = map["recentlyAdded"] as? [NSDictionary] {
            
            recentlyAdded.forEach({
                
                if let file = $0.value(forKey: "file") as? String,
                    let timestamp = $0.value(forKey: "time") as? String {
                    
                    state.recentlyAdded.append((URL(fileURLWithPath: file), Date.fromString(timestamp)))
                }
            })
        }
        
        if let recentlyPlayed = map["recentlyPlayed"] as? [NSDictionary] {
            
            recentlyPlayed.forEach({
                
                if let file = $0.value(forKey: "file") as? String,
                    let timestamp = $0.value(forKey: "time") as? String {
                    
                    state.recentlyPlayed.append((URL(fileURLWithPath: file), Date.fromString(timestamp)))
                }
            })
        }
        
        return state
    }
}

class BookmarkState {
    
    var name: String = ""
    var file: URL
    var startPosition: Double = 0
    var endPosition: Double?
    
    init(_ name: String, _ file: URL, _ startPosition: Double, _ endPosition: Double?) {
        self.name = name
        self.file = file
        self.startPosition = startPosition
        self.endPosition = endPosition
    }
    
    static func deserialize(_ bookmarkMap: NSDictionary) -> BookmarkState? {
        
        if let name = bookmarkMap.value(forKey: "name") as? String, let file = bookmarkMap.value(forKey: "file") as? String, let startPosition = bookmarkMap.value(forKey: "startPosition") as? NSNumber {
            
            let endPosition = bookmarkMap.value(forKey: "endPosition") as? NSNumber
            return BookmarkState(name, URL(fileURLWithPath: file), startPosition.doubleValue, endPosition?.doubleValue)
        }
        
        return nil
    }
}

extension PlaybackProfile {
    
    static func deserialize(_ map: NSDictionary) -> PlaybackProfile? {
        
        var profileFile: URL?
        var profileLastPosition: Double = AppDefaults.lastTrackPosition
        
        if let file = map["file"] as? String {
            profileFile = URL(fileURLWithPath: file)
        }
        
        if let posn = map["lastPosition"] as? NSNumber {
            profileLastPosition = posn.doubleValue
        }
        
        return PlaybackProfile(profileFile!, profileLastPosition)
    }
}

/*
 Encapsulates all application state. It is persisted to disk upon exit and loaded into the application upon startup.
 
 TODO: Make this class conform to different protocols for access/mutation
 */
class AppState {
    
    var ui: UIState = UIState()
    var audioGraph: AudioGraphState = AudioGraphState()
    var playlist: PlaylistState = PlaylistState()
    var playbackSequence: PlaybackSequenceState = PlaybackSequenceState()
    var history: HistoryState = HistoryState()
    var favorites: [URL] = [URL]()
    var bookmarks: [BookmarkState] = []
    var playbackProfiles: [PlaybackProfile] = []
    
    static let defaults: AppState = AppState()
    
    // Produces an AppState object from deserialized JSON
    static func deserialize(_ jsonObject: NSDictionary) -> AppState {
        
        let state = AppState()
        
        if let uiDict = (jsonObject["ui"] as? NSDictionary) {
            state.ui = UIState.deserialize(uiDict) as! UIState
        }
        
        if let map = (jsonObject["audioGraph"] as? NSDictionary) {
            state.audioGraph = AudioGraphState.deserialize(map) as! AudioGraphState
        }
        
        if let playbackSequenceDict = (jsonObject["playbackSequence"] as? NSDictionary) {
            state.playbackSequence = PlaybackSequenceState.deserialize(playbackSequenceDict) as! PlaybackSequenceState
        }
        
        if let playlistDict = (jsonObject["playlist"] as? NSDictionary) {
            state.playlist = PlaylistState.deserialize(playlistDict) as! PlaylistState
        }
        
        if let historyDict = (jsonObject["history"] as? NSDictionary) {
            state.history = HistoryState.deserialize(historyDict) as! HistoryState
        }
        
        if let favoritesArr = (jsonObject["favorites"] as? NSArray) {
            favoritesArr.forEach({
                
                if let file = $0 as? String {
                    state.favorites.append(URL(fileURLWithPath: file))
                }
            })
        }
        
        if let bookmarksArr = (jsonObject["bookmarks"] as? NSArray) {

            bookmarksArr.forEach({

                if let bookmarkDict = $0 as? NSDictionary, let bookmark = BookmarkState.deserialize(bookmarkDict) {
                    state.bookmarks.append(bookmark)
                }
            })
        }

        if let playbackProfilesArr = (jsonObject["playbackProfiles"] as? NSArray) {

            playbackProfilesArr.forEach({
                
                if let dict = $0 as? NSDictionary, let profile = PlaybackProfile.deserialize(dict) {
                    state.playbackProfiles.append(profile)
                }
            })
        }
        
        return state
    }
}
