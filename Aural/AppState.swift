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
    var player: PlayerUIState = PlayerUIState()
    var playlist: PlaylistUIState = PlaylistUIState()
    var effects: EffectsUIState = EffectsUIState()
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = UIState()
        
        if let windowLayoutMap = map["windowLayout"] as? NSDictionary {
            state.windowLayout = WindowLayoutState.deserialize(windowLayoutMap) as! WindowLayoutState
        }
        
        if let playerMap = map["player"] as? NSDictionary {
            state.player = PlayerUIState.deserialize(playerMap) as! PlayerUIState
        }
        
        if let effectsMap = map["effects"] as? NSDictionary {
            state.effects = EffectsUIState.deserialize(effectsMap) as! EffectsUIState
        }
        
        if let playlistMap = map["playlist"] as? NSDictionary {
            state.playlist = PlaylistUIState.deserialize(playlistMap) as! PlaylistUIState
        }
        
        return state
    }
}

class PlaylistUIState: PersistentState {
    
    var textSize: TextSizeScheme = .normal
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = PlaylistUIState()
        state.textSize = mapEnum(map, "textSize", TextSizeScheme.normal)
        
        return state
    }
}

class EffectsUIState: PersistentState {
    
    var textSize: TextSizeScheme = .normal
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = EffectsUIState()
        state.textSize = mapEnum(map, "textSize", TextSizeScheme.normal)
        
        return state
    }
}

class PlayerUIState: PersistentState {
    
    var viewType: PlayerViewType = .defaultView
    
    var showAlbumArt: Bool = true
    var showTrackInfo: Bool = true
    var showSequenceInfo: Bool = true
    var showPlayingTrackFunctions: Bool = true
    var showControls: Bool = true
    var showTimeElapsedRemaining: Bool = true
    
    var timeElapsedDisplayType: TimeElapsedDisplayType = .formatted
    var timeRemainingDisplayType: TimeRemainingDisplayType = .formatted
    
    var textSize: TextSizeScheme = .normal
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = PlayerUIState()
        
        state.viewType = mapEnum(map, "viewType", PlayerViewType.defaultView)
        
        state.showAlbumArt = mapDirectly(map, "showAlbumArt", true)
        state.showTrackInfo = mapDirectly(map, "showTrackInfo", true)
        state.showSequenceInfo = mapDirectly(map, "showSequenceInfo", true)
        state.showControls = mapDirectly(map, "showControls", true)
        state.showTimeElapsedRemaining = mapDirectly(map, "showTimeElapsedRemaining", true)
        state.showPlayingTrackFunctions = mapDirectly(map, "showPlayingTrackFunctions", true)
        
        state.timeElapsedDisplayType = mapEnum(map, "timeElapsedDisplayType", TimeElapsedDisplayType.formatted)
        state.timeRemainingDisplayType = mapEnum(map, "timeRemainingDisplayType", TimeRemainingDisplayType.formatted)
        
        state.textSize = mapEnum(map, "textSize", TextSizeScheme.normal)
        
        return state
    }
}

fileprivate func mapEnum<T: RawRepresentable>(_ map: NSDictionary, _ key: String, _ defaultValue: T) -> T where T.RawValue == String {
    if let rawVal = map[key] as? String, let enumVal = T.self.init(rawValue: rawVal) {return enumVal} else {return defaultValue}
}

fileprivate func mapDirectly<T: Any>(_ map: NSDictionary, _ key: String, _ defaultValue: T) -> T {
    if let value = map[key] as? T {return value} else {return defaultValue}
}

fileprivate func mapDirectly<T: Any>(_ map: NSDictionary, _ key: String) -> T? {
    if let value = map[key] as? T {return value} else {return nil}
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
                
                if let layoutName = layout["name"] as? String {
                    
                    let layoutShowEffects: Bool? = mapDirectly(layout, "showEffects")
                    let layoutShowPlaylist: Bool? = mapDirectly(layout, "showPlaylist")
                    
                    var layoutMainWindowOrigin: NSPoint?
                    var layoutEffectsWindowOrigin: NSPoint?
                    var layoutPlaylistWindowFrame: NSRect?
                    
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
                    if layoutShowEffects != nil && layoutShowPlaylist != nil && layoutMainWindowOrigin != nil {
                        
                        if ((layoutShowEffects! && layoutEffectsWindowOrigin != nil) || !layoutShowEffects!) {
                            
                            if ((layoutShowPlaylist! && layoutPlaylistWindowFrame != nil) || !layoutShowPlaylist!) {
                                
                                let newLayout = WindowLayout(layoutName, layoutShowEffects!, layoutShowPlaylist!, layoutMainWindowOrigin!, layoutEffectsWindowOrigin, layoutPlaylistWindowFrame, false)
                                
                                state.userLayouts.append(newLayout)
                            }
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
    
    return MasterPreset(name, eqPreset, pitchPreset, timePreset, reverbPreset, delayPreset, filterPreset, false)
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
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
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
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let timeState: TimeUnitState = TimeUnitState()
        
        timeState.state = mapEnum(map, "state", AppDefaults.pitchState)
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
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
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
    let state = mapEnum(map, "state", AppDefaults.reverbState)
    
    let amount: Float = mapNumeric(map, "amount", AppDefaults.delayAmount)
    let time: Double = mapNumeric(map, "time", AppDefaults.delayTime)
    let feedback: Float = mapNumeric(map, "feedback", AppDefaults.delayFeedback)
    let cutoff: Float = mapNumeric(map, "lowPassCutoff", AppDefaults.delayLowPassCutoff)
    
    return DelayPreset(name, state, amount, time, feedback, cutoff, false)
}

class FilterUnitState: FXUnitState<FilterPreset>, PersistentState {
    
    var bands: [FilterBand] = []
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
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

fileprivate func deserializeFilterPreset(_ map: NSDictionary) -> FilterPreset {
    
    let name = map["name"] as? String ?? ""
    let state = mapEnum(map, "state", AppDefaults.reverbState)
    
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
        
        (map["tracks"] as? [String])?.forEach({state.tracks.append(URL(fileURLWithPath: $0))})
        
        (map["gaps"] as? [NSDictionary])?.forEach({
            
            let gap = PlaybackGapState.deserialize($0) as! PlaybackGapState
            
            // Gap is useless without an associated track
            if let track = gap.track {
                
                if gap.position == .beforeTrack {
                    state._transient_gapsBeforeMap[track] = gap
                } else {
                    state._transient_gapsAfterMap[track] = gap
                }
                
                state.gaps.append(gap)
            }
        })
        
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
            state.duration = mapNumeric(map, "duration", AppDefaults.playbackGapDuration)
            state.position = mapEnum(map, "position", AppDefaults.playbackGapPosition)
            state.type = mapEnum(map, "type", AppDefaults.playbackGapType)
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
        
        state.repeatMode = mapEnum(map, "repeatMode", AppDefaults.repeatMode)
        state.shuffleMode = mapEnum(map, "shuffleMode", AppDefaults.shuffleMode)
        
        return state
    }
}

class HistoryState: PersistentState {
    
    var recentlyAdded: [(file: URL, name: String, time: Date)] = [(file: URL, name: String, time: Date)]()
    var recentlyPlayed: [(file: URL, name: String, time: Date)] = [(file: URL, name: String, time: Date)]()
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = HistoryState()
        
        if let recentlyAdded = map["recentlyAdded"] as? [NSDictionary] {
            recentlyAdded.forEach({if let item = deserializeHistoryItem($0) {state.recentlyAdded.append(item)}})
        }
        
        if let recentlyPlayed = map["recentlyPlayed"] as? [NSDictionary] {
            recentlyPlayed.forEach({if let item = deserializeHistoryItem($0) {state.recentlyPlayed.append(item)}})
        }
        
        return state
    }
    
    private static func deserializeHistoryItem(_ map: NSDictionary) -> (file: URL, name: String, time: Date)? {
        
        if let file = map["file"] as? String, let name = map["name"] as? String, let timestamp = map["time"] as? String {
            return (URL(fileURLWithPath: file), name, Date.fromString(timestamp))
        }
        
        return nil
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
        
        if let name = bookmarkMap["name"] as? String, let file = bookmarkMap["file"] as? String {
            
            let startPosition: Double = mapNumeric(bookmarkMap, "startPosition", AppDefaults.lastTrackPosition)
            let endPosition: Double? = mapNumeric(bookmarkMap, "endPosition")
            return BookmarkState(name, URL(fileURLWithPath: file), startPosition, endPosition)
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
            profileLastPosition = mapNumeric(map, "lastPosition", AppDefaults.lastTrackPosition)
            return PlaybackProfile(profileFile!, profileLastPosition)
        }
        
        return nil
    }
}

class TranscoderState: PersistentState {
    
    var entries: [URL: URL] = [:]
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = TranscoderState()
        
        if let entries = map["entries"] as? NSDictionary {
            
            for (inFilePath, outFilePath) in entries {
                
                let inFile = URL(fileURLWithPath: String(describing: inFilePath))
                let outFile = URL(fileURLWithPath: String(describing: outFilePath))
                state.entries[inFile] = outFile
            }
        }
        
        return state
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
    var transcoder: TranscoderState = TranscoderState()
    
    var history: HistoryState = HistoryState()
    var favorites: [(file: URL, name: String)] = [(file: URL, name: String)]()
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
        
        if let transcoderDict = (jsonObject["transcoder"] as? NSDictionary) {
            state.transcoder = TranscoderState.deserialize(transcoderDict) as! TranscoderState
        }
        
        if let historyDict = (jsonObject["history"] as? NSDictionary) {
            state.history = HistoryState.deserialize(historyDict) as! HistoryState
        }
        
        if let favoritesArr = (jsonObject["favorites"] as? [NSDictionary]) {
            favoritesArr.forEach({
                if let file = $0["file"] as? String, let name = $0["name"] as? String {
                    state.favorites.append((URL(fileURLWithPath: file), name))
                }
            })
        }
        
        (jsonObject["bookmarks"] as? NSArray)?.forEach({
            
            if let bookmarkDict = $0 as? NSDictionary, let bookmark = BookmarkState.deserialize(bookmarkDict) {
                state.bookmarks.append(bookmark)
            }
        })
        
        (jsonObject["playbackProfiles"] as? NSArray)?.forEach({
            
            if let dict = $0 as? NSDictionary, let profile = PlaybackProfile.deserialize(dict) {
                state.playbackProfiles.append(profile)
            }
        })
        
        return state
    }
}
