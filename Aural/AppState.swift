import Cocoa

// Marks an object as having state that needs to be persisted
protocol PersistentModelObject {
    
    // Retrieves persistent state for this model object
    func persistentState() -> PersistentState
}

// Marks an object as being suitable for persistence, i.e. it is serializable/deserializable
protocol PersistentState {
    
    // Produces a serialiable representation of this state object
    func toSerializableMap() -> NSDictionary
    
    // Produces a serialiable representation of this state object
    func toSerializableArray() -> NSArray
    
    // Constructs an instance of this state object from the given map
    static func deserialize(_ map: NSDictionary) -> PersistentState
}

extension PersistentState {
    
    func toSerializableArray() -> NSArray {
        return NSArray(array: [])
    }
    
    func toSerializableMap() -> NSDictionary {
        return [NSString: AnyObject]() as NSDictionary
    }
}

/*
    Encapsulates UI state
 */
class UIState: PersistentState {
    
    var windowLayoutState: WindowLayoutState
    var playerState: PlayerState
    
    init() {
        self.windowLayoutState = WindowLayoutState()
        self.playerState = PlayerState()
    }
    
    func toSerializableMap() -> NSDictionary {
        
        var map = [NSString: AnyObject]()
        
        map["windowLayout"] = windowLayoutState.toSerializableMap()
        map["player"] = playerState.toSerializableMap()
        
        return map as NSDictionary
    }
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = UIState()
        
        if let windowLayoutMap = map["windowLayout"] as? NSDictionary {
            state.windowLayoutState = WindowLayoutState.deserialize(windowLayoutMap) as! WindowLayoutState
        }
        
        if let playerMap = map["player"] as? NSDictionary {
            state.playerState = PlayerState.deserialize(playerMap) as! PlayerState
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
    
    func toSerializableMap() -> NSDictionary {
        
        var map = [NSString: AnyObject]()
        
        map["viewType"] = viewType.rawValue as AnyObject
        
        map["showAlbumArt"] = showAlbumArt as AnyObject
        map["showTrackInfo"] = showTrackInfo as AnyObject
        map["showSequenceInfo"] = showSequenceInfo as AnyObject
        map["showControls"] = showControls as AnyObject
        map["showTimeElapsedRemaining"] = showTimeElapsedRemaining as AnyObject
        map["showPlayingTrackFunctions"] = showPlayingTrackFunctions as AnyObject
        
        map["timeElapsedDisplayType"] = timeElapsedDisplayType.rawValue as AnyObject
        map["timeRemainingDisplayType"] = timeRemainingDisplayType.rawValue as AnyObject
        
        return map as NSDictionary
    }
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = PlayerState()
        
        if let viewTypeStr = map["viewType"] as? String, let viewType = PlayerViewType(rawValue: viewTypeStr) {
            state.viewType = viewType
        }
        
        if let showAlbumArt = map["showAlbumArt"] as? Bool {
            state.showAlbumArt = showAlbumArt
        }
        
        if let showTrackInfo = map["showTrackInfo"] as? Bool {
            state.showTrackInfo = showTrackInfo
        }
        
        if let showSequenceInfo = map["showSequenceInfo"] as? Bool {
            state.showSequenceInfo = showSequenceInfo
        }
        
        if let showControls = map["showControls"] as? Bool {
            state.showControls = showControls
        }
        
        if let showTimeElapsedRemaining = map["showTimeElapsedRemaining"] as? Bool {
            state.showTimeElapsedRemaining = showTimeElapsedRemaining
        }
        
        if let showPlayingTrackFunctions = map["showPlayingTrackFunctions"] as? Bool {
            state.showPlayingTrackFunctions = showPlayingTrackFunctions
        }
        
        if let displayTypeStr = map["timeElapsedDisplayType"] as? String, let timeElapsedDisplayType = TimeElapsedDisplayType(rawValue: displayTypeStr) {
            state.timeElapsedDisplayType = timeElapsedDisplayType
        }
        
        if let displayTypeStr = map["timeRemainingDisplayType"] as? String, let timeRemainingDisplayType = TimeRemainingDisplayType(rawValue: displayTypeStr) {
            state.timeRemainingDisplayType = timeRemainingDisplayType
        }
        
        return state
    }
}

class WindowLayoutState: PersistentState {
    
    var showEffects: Bool = true
    var showPlaylist: Bool = true
    
    // TODO: Revisit this
    var mainWindowOrigin: NSPoint = NSPoint.zero
    var effectsWindowOrigin: NSPoint? = nil
    var playlistWindowFrame: NSRect? = nil
    
    var userWindowLayouts: [WindowLayout] = [WindowLayout]()
    
    func toSerializableMap() -> NSDictionary {
        
        var map = [NSString: AnyObject]()
        
        map["showPlaylist"] = showPlaylist as AnyObject
        map["showEffects"] = showEffects as AnyObject
        
        map["mainWindow_x"] = mainWindowOrigin.x as NSNumber
        map["mainWindow_y"] = mainWindowOrigin.y as NSNumber
        
        if let origin = effectsWindowOrigin {
            
            map["effectsWindow_x"] = origin.x as NSNumber
            map["effectsWindow_y"] = origin.y as NSNumber
        }
        
        if let frame = playlistWindowFrame {
            
            map["playlistWindow_x"] = frame.origin.x as NSNumber
            map["playlistWindow_y"] = frame.origin.y as NSNumber
            map["playlistWindow_width"] = frame.width as NSNumber
            map["playlistWindow_height"] = frame.height as NSNumber
        }
        
        var userWindowLayoutsArr = [[NSString: AnyObject]]()
        for layout in userWindowLayouts {
            
            var layoutDict = [NSString: AnyObject]()
            
            layoutDict["name"] = layout.name as AnyObject
            
            layoutDict["showPlaylist"] = layout.showPlaylist as AnyObject
            layoutDict["showEffects"] = layout.showEffects as AnyObject
            
            layoutDict["mainWindow_x"] = layout.mainWindowOrigin.x as NSNumber
            layoutDict["mainWindow_y"] = layout.mainWindowOrigin.y as NSNumber
            
            if let origin = layout.effectsWindowOrigin {
            
                layoutDict["effectsWindow_x"] = origin.x as NSNumber
                layoutDict["effectsWindow_y"] = origin.y as NSNumber
            }
            
            if let frame = layout.playlistWindowFrame {
            
                layoutDict["playlistWindow_x"] = frame.origin.x as NSNumber
                layoutDict["playlistWindow_y"] = frame.origin.y as NSNumber
                layoutDict["playlistWindow_width"] = frame.width as NSNumber
                layoutDict["playlistWindow_height"] = frame.height as NSNumber
            }
            
            userWindowLayoutsArr.append(layoutDict)
        }
        
        map["userLayouts"] = NSArray(array: userWindowLayoutsArr)
        
        return map as NSDictionary
    }
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = WindowLayoutState()
        
        if let showPlaylist = map["showPlaylist"] as? Bool {
            state.showPlaylist = showPlaylist
        }
        
        if let showEffects = map["showEffects"] as? Bool {
            state.showEffects = showEffects
        }
        
        if let mainWindowX = map["mainWindow_x"] as? NSNumber, let mainWindowY = map["mainWindow_y"] as? NSNumber {
            state.mainWindowOrigin = NSPoint(x: CGFloat(mainWindowX.floatValue), y: CGFloat(mainWindowY.floatValue))
        }
        
        if let effectsWindowX = map["effectsWindow_x"] as? NSNumber, let effectsWindowY = map["effectsWindow_y"] as? NSNumber {
            state.effectsWindowOrigin = NSPoint(x: CGFloat(effectsWindowX.floatValue), y: CGFloat(effectsWindowY.floatValue))
        }
        
        if let playlistWindowX = map["playlistWindow_x"] as? NSNumber, let playlistWindowY = map["playlistWindow_y"] as? NSNumber {
            
            let origin  = NSPoint(x: CGFloat(playlistWindowX.floatValue), y: CGFloat(playlistWindowY.floatValue))
            
            if let playlistWindowWidth = map["playlistWindow_width"] as? NSNumber, let playlistWindowHeight = map["playlistWindow_height"] as? NSNumber {
                
                state.playlistWindowFrame = NSRect(x: origin.x, y: origin.y, width: CGFloat(playlistWindowWidth.floatValue), height: CGFloat(playlistWindowHeight.floatValue))
            }
        }
        
        if let userLayouts = map["userLayouts"] as? [NSDictionary] {
            
            userLayouts.forEach({
                
                let layout = $0
                
                var layoutName: String?
                
                var layoutShowEffects: Bool?
                var layoutShowPlaylist: Bool?
                
                var layoutMainWindowOrigin: NSPoint?
                var layoutEffectsWindowOrigin: NSPoint?
                var layoutPlaylistWindowFrame: NSRect?
                
                if let name = layout["name"] as? String {
                    layoutName = name
                }
                
                if let showPlaylist = layout["showPlaylist"] as? Bool {
                    layoutShowPlaylist = showPlaylist
                }
                
                if let showEffects = layout["showEffects"] as? Bool {
                    layoutShowEffects = showEffects
                }
                
                if let mainWindowX = layout["mainWindow_x"] as? NSNumber {
                    
                    if let mainWindowY = layout["mainWindow_y"] as? NSNumber {
                        layoutMainWindowOrigin = NSPoint(x: CGFloat(mainWindowX.floatValue), y: CGFloat(mainWindowY.floatValue))
                    }
                }
                
                if let effectsWindowX = layout["effectsWindow_x"] as? NSNumber, let effectsWindowY = layout["effectsWindow_y"] as? NSNumber {
                    layoutEffectsWindowOrigin = NSPoint(x: CGFloat(effectsWindowX.floatValue), y: CGFloat(effectsWindowY.floatValue))
                }
                
                if let playlistWindowX = layout["playlistWindow_x"] as? NSNumber, let playlistWindowY = layout["playlistWindow_y"] as? NSNumber {
                    
                    let origin  = NSPoint(x: CGFloat(playlistWindowX.floatValue), y: CGFloat(playlistWindowY.floatValue))
                    
                    if let playlistWindowWidth = layout["playlistWindow_width"] as? NSNumber, let playlistWindowHeight = layout["playlistWindow_height"] as? NSNumber {
                        
                        layoutPlaylistWindowFrame = NSRect(x: origin.x, y: origin.y, width: CGFloat(playlistWindowWidth.floatValue), height: CGFloat(playlistWindowHeight.floatValue))
                    }
                }
                
                // Make sure you have all the required info
                if layoutName != nil && layoutShowEffects != nil && layoutShowPlaylist != nil && layoutMainWindowOrigin != nil {
                    
                    if ((layoutShowEffects! && layoutEffectsWindowOrigin != nil) || !layoutShowEffects!) {
                        
                        if ((layoutShowPlaylist! && layoutPlaylistWindowFrame != nil) || !layoutShowPlaylist!) {
                            
                            let newLayout = WindowLayout(layoutName!, layoutShowEffects!, layoutShowPlaylist!, layoutMainWindowOrigin!, layoutEffectsWindowOrigin, layoutPlaylistWindowFrame, false)
                            
                            state.userWindowLayouts.append(newLayout)
                        }
                    }
                }
            })
        }
        
        return state
    }
}

class FXUnitState<T: EffectsUnitPreset> {
    
    var unitState: EffectsUnitState = .bypassed
    var userPresets: [T] = [T]()
}

class EQUnitState: FXUnitState<EQPreset>, PersistentState {
    
    var type: EQType = AppDefaults.eqType
    var globalGain: Float = AppDefaults.eqGlobalGain
    var bands: [Int: Float] = [Int: Float]() // Index -> Gain
    var sync: Bool = AppDefaults.eqSync

    func toSerializableMap() -> NSDictionary {
        
        var map = [NSString: AnyObject]()
        
        map["state"] = unitState.rawValue as AnyObject
        map["type"] = type.rawValue as AnyObject
        map["sync"] = sync as AnyObject
        map["globalGain"] = globalGain as NSNumber
        
        var eqBandsDict = [NSString: NSNumber]()
        for (index, gain) in bands {
            eqBandsDict[String(index) as NSString] = gain as NSNumber
        }
        map["bands"] = eqBandsDict as AnyObject
        
        var eqUserPresetsArr = [[NSString: AnyObject]]()
        for preset in userPresets {
            
            var presetDict = [NSString: AnyObject]()
            presetDict["name"] = preset.name as AnyObject
            
            presetDict["globalGain"] = preset.globalGain as NSNumber
            
            var presetBandsDict = [NSString: NSNumber]()
            for (index, gain) in preset.bands {
                presetBandsDict[String(index) as NSString] = gain as NSNumber
            }
            presetDict["bands"] = presetBandsDict as AnyObject
            
            
            eqUserPresetsArr.append(presetDict)
        }
        map["userPresets"] = NSArray(array: eqUserPresetsArr)

        return map as NSDictionary
    }
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let eqState: EQUnitState = EQUnitState()
        
        if let state = map["state"] as? String {
            
            if let unitState = EffectsUnitState(rawValue: state) {
                eqState.unitState = unitState
            }
        }
        
        if let typeStr = map["type"] as? String, let type = EQType(rawValue: typeStr) {
            eqState.type = type
        }
        
        if let sync = map["sync"] as? Bool {
            eqState.sync = sync
        }
        
        if let globalGain = map["globalGain"] as? NSNumber {
            eqState.globalGain = globalGain.floatValue
        }
        
        if let eqBands: NSDictionary = map["bands"] as? NSDictionary {
            
            for (index, gain) in eqBands {
                
                if let indexStr = index as? String {
                    
                    if let indexInt = Int(indexStr) {
                        
                        if let gainNum = gain as? NSNumber {
                            eqState.bands[indexInt] = gainNum.floatValue
                        }
                    }
                }
            }
        }
        
        // EQ User presets
        if let userPresets = map["userPresets"] as? [NSDictionary] {
            
            userPresets.forEach({
                
                var presetName: String?
                
                // TODO: Get this from a default value constant
                var presetGlobalGain: Float = 0
                
                if let name = $0["name"] as? String {
                    presetName = name
                }
                
                var presetBands: [Int: Float] = [Int: Float]()
                
                if let presetBandsDict: NSDictionary = $0["bands"] as? NSDictionary {
                    
                    for (index, gain) in presetBandsDict {
                        
                        if let indexStr = index as? String {
                            
                            if let indexInt = Int(indexStr) {
                                
                                if let gainNum = gain as? NSNumber {
                                    presetBands[indexInt] = gainNum.floatValue
                                }
                            }
                        }
                    }
                }
                
                if let globalGain = $0["globalGain"] as? NSNumber {
                    presetGlobalGain = globalGain.floatValue
                }
                
                // Preset must have a name
                if let presetName = presetName {
                    eqState.userPresets.append(EQPreset(presetName, .active, presetBands, presetGlobalGain, false))
                }
            })
        }
        
        return eqState
    }
}

class PitchUnitState: FXUnitState<PitchPreset>, PersistentState {
    
    var pitch: Float = AppDefaults.pitch
    var overlap: Float = AppDefaults.pitchOverlap
    
    func toSerializableMap() -> NSDictionary {
        
        var map = [NSString: AnyObject]()
        map["state"] = unitState.rawValue as AnyObject
        map["pitch"] = pitch as NSNumber
        map["overlap"] = overlap as NSNumber
        
        var pitchUserPresetsArr = [[NSString: AnyObject]]()
        for preset in userPresets {
            
            var presetDict = [NSString: AnyObject]()
            presetDict["name"] = preset.name as AnyObject
            presetDict["pitch"] = preset.pitch as NSNumber
            presetDict["overlap"] = preset.overlap as NSNumber
            
            pitchUserPresetsArr.append(presetDict)
        }
        map["userPresets"] = NSArray(array: pitchUserPresetsArr)
        
        return map as NSDictionary
    }
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state: PitchUnitState = PitchUnitState()
        
        if let unitState = map["state"] as? String {
            if let pitchState = EffectsUnitState(rawValue: unitState) {
                state.unitState = pitchState
            }
        }
        
        if let pitch = map["pitch"] as? NSNumber {
            state.pitch = pitch.floatValue
        }
        
        if let overlap = map["overlap"] as? NSNumber {
            state.overlap = overlap.floatValue
        }
        
        // Pitch user presets
        if let userPresets = map["userPresets"] as? [NSDictionary] {
            
            userPresets.forEach({
                
                var presetName: String?
                var presetPitch: Float?
                var presetOverlap: Float?
                
                if let name = $0["name"] as? String {
                    presetName = name
                }
                
                if let pitch = $0["pitch"] as? NSNumber {
                    presetPitch = pitch.floatValue
                }
                
                if let overlap = $0["overlap"] as? NSNumber {
                    presetOverlap = overlap.floatValue
                }
                
                // Preset must have a name
                if let presetName = presetName {
                    state.userPresets.append(PitchPreset(presetName, .active, presetPitch!, presetOverlap!, false))
                }
            })
        }
        
        return state
    }
}

class TimeUnitState: FXUnitState<TimePreset>, PersistentState {
    
    var rate: Float = AppDefaults.timeStretchRate
    var shiftPitch: Bool = AppDefaults.timeShiftPitch
    var overlap: Float = AppDefaults.timeOverlap
    
    func toSerializableMap() -> NSDictionary {
        
        var map = [NSString: AnyObject]()
        map["state"] = unitState.rawValue as AnyObject
        map["rate"] = rate as NSNumber
        map["overlap"] = overlap as NSNumber
        map["shiftPitch"] = shiftPitch as AnyObject
        
        var timeUserPresetsArr = [[NSString: AnyObject]]()
        for preset in userPresets {
            
            var presetDict = [NSString: AnyObject]()
            presetDict["name"] = preset.name as AnyObject
            presetDict["rate"] = preset.rate as NSNumber
            presetDict["overlap"] = preset.overlap as NSNumber
            presetDict["shiftPitch"] = preset.pitchShift as AnyObject
            
            timeUserPresetsArr.append(presetDict)
        }
        map["userPresets"] = NSArray(array: timeUserPresetsArr)
        
        return map as NSDictionary
    }
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let timeState: TimeUnitState = TimeUnitState()
        
        if let stateStr = map["state"] as? String, let unitState = EffectsUnitState(rawValue: stateStr) {
            timeState.unitState = unitState
        }
        
        if let rate = map["rate"] as? NSNumber {
            timeState.rate = rate.floatValue
        }
        
        if let timeOverlap = map["overlap"] as? NSNumber {
            timeState.overlap = timeOverlap.floatValue
        }
        
        if let shiftPitch = map["shiftPitch"] as? Bool {
            timeState.shiftPitch = shiftPitch
        }
        
        // Time user presets
        if let userPresets = map["userPresets"] as? [NSDictionary] {
            
            userPresets.forEach({
                
                var presetName: String?
                var presetRate: Float?
                var presetOverlap: Float?
                var presetPitchShift: Bool?
                
                if let name = $0["name"] as? String {
                    presetName = name
                }
                
                if let rate = $0["rate"] as? NSNumber {
                    presetRate = rate.floatValue
                }
                
                if let overlap = $0["overlap"] as? NSNumber {
                    presetOverlap = overlap.floatValue
                }
                
                if let pitchShift = $0["shiftPitch"] as? Bool {
                    presetPitchShift = pitchShift
                }
                
                // Preset must have a name
                if let presetName = presetName {
                    timeState.userPresets.append(TimePreset(presetName, .active, presetRate!,  presetOverlap!, presetPitchShift!, false))
                }
            })
        }
        
        return timeState
    }
}

class ReverbUnitState: FXUnitState<ReverbPreset>, PersistentState {
    
    var space: ReverbSpaces = AppDefaults.reverbSpace
    var amount: Float = AppDefaults.reverbAmount
    
    func toSerializableMap() -> NSDictionary {
        
        var map = [NSString: AnyObject]()
        
        map["state"] = unitState.rawValue as AnyObject
        map["space"] = space.rawValue as AnyObject
        map["amount"] = amount as NSNumber
        
        var reverbUserPresetsArr = [[NSString: AnyObject]]()
        for preset in userPresets {
            
            var presetDict = [NSString: AnyObject]()
            presetDict["name"] = preset.name as AnyObject
            presetDict["space"] = preset.space.rawValue as AnyObject
            presetDict["amount"] = preset.amount as NSNumber
            
            reverbUserPresetsArr.append(presetDict)
        }

        map["userPresets"] = NSArray(array: reverbUserPresetsArr)
        
        return map as NSDictionary
    }
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let reverbState: ReverbUnitState = ReverbUnitState()
        
        if let stateStr = map["state"] as? String, let unitState = EffectsUnitState(rawValue: stateStr) {
            reverbState.unitState = unitState
        }
        
        if let spaceStr = map["space"] as? String, let space = ReverbSpaces(rawValue: spaceStr) {
            reverbState.space = space
        }
        
        if let amount = map["amount"] as? NSNumber {
            reverbState.amount = amount.floatValue
        }
        
        // Reverb user presets
        if let userPresets = map["userPresets"] as? [NSDictionary] {
            
            userPresets.forEach({
                
                var presetName: String?
                var presetSpace: String?
                var presetAmount: Float?
                
                if let name = $0["name"] as? String {
                    presetName = name
                }
                
                if let space = $0["space"] as? String {
                    presetSpace = space
                }
                
                if let amount = $0["amount"] as? NSNumber {
                    presetAmount = amount.floatValue
                }
                
                // Preset must have a name
                if let presetName = presetName {
                    
                    reverbState.userPresets.append(ReverbPreset(presetName, .active, ReverbSpaces(rawValue: presetSpace!)!, presetAmount!, false))
                }
            })
        }
        
        return reverbState
    }
}

class DelayUnitState: FXUnitState<DelayPreset>, PersistentState {
    
    var amount: Float = AppDefaults.delayAmount
    var time: Double = AppDefaults.delayTime
    var feedback: Float = AppDefaults.delayFeedback
    var lowPassCutoff: Float = AppDefaults.delayLowPassCutoff
    
    func toSerializableMap() -> NSDictionary {
        
        var map = [NSString: AnyObject]()
        
        map["state"] = unitState.rawValue as AnyObject
        map["amount"] = amount as NSNumber
        map["time"] = time as NSNumber
        map["feedback"] = feedback as NSNumber
        map["lowPassCutoff"] = lowPassCutoff as NSNumber
        
        var delayUserPresetsArr = [[NSString: AnyObject]]()
        for preset in userPresets {
            
            var presetDict = [NSString: AnyObject]()
            presetDict["name"] = preset.name as AnyObject
            presetDict["amount"] = preset.amount as NSNumber
            presetDict["time"] = preset.time as NSNumber
            presetDict["feedback"] = preset.feedback as NSNumber
            presetDict["lowPassCutoff"] = preset.cutoff as NSNumber
            
            delayUserPresetsArr.append(presetDict)
        }
        
        map["userPresets"] = NSArray(array: delayUserPresetsArr)
        
        return map as NSDictionary
    }
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let delayState: DelayUnitState = DelayUnitState()
        
        if let stateStr = map["state"] as? String, let state = EffectsUnitState(rawValue: stateStr) {
            delayState.unitState = state
        }
        
        if let amount = map["amount"] as? NSNumber {
            delayState.amount = amount.floatValue
        }
        
        if let time = map["time"] as? NSNumber {
            delayState.time = time.doubleValue
        }
        
        if let feedback = map["feedback"] as? NSNumber {
            delayState.feedback = feedback.floatValue
        }
        
        if let cutoff = map["lowPassCutoff"] as? NSNumber {
            delayState.lowPassCutoff = cutoff.floatValue
        }
        
        // Delay user presets
        if let userPresets = map["userPresets"] as? [NSDictionary] {
            
            userPresets.forEach({
                
                var presetName: String?
                var presetAmount: Float?
                var presetTime: Double?
                var presetFeedback: Float?
                var presetCutoff: Float?
                
                if let name = $0["name"] as? String {
                    presetName = name
                }
                
                if let amount = $0["amount"] as? NSNumber {
                    presetAmount = amount.floatValue
                }
                
                if let time = $0["time"] as? NSNumber {
                    presetTime = time.doubleValue
                }
                
                if let feedback = $0["feedback"] as? NSNumber {
                    presetFeedback = feedback.floatValue
                }
                
                if let cutoff = $0["lowPassCutoff"] as? NSNumber {
                    presetCutoff = cutoff.floatValue
                }
                
                // Preset must have a name
                if let presetName = presetName {
                    delayState.userPresets.append(DelayPreset(presetName, .active, presetAmount!, presetTime!, presetFeedback!, presetCutoff!, false))
                }
            })
        }
        
        return delayState
    }
}

/*
    Encapsulates audio graph state
 */
// TODO: Separate this class into separate classes for different effects units
class AudioGraphState: PersistentState {
    
    var volume: Float = AppDefaults.volume
    var muted: Bool = AppDefaults.muted
    var balance: Float = AppDefaults.balance
    
    var masterState: EffectsUnitState = AppDefaults.masterState
    var masterUserPresets: [MasterPreset] = [MasterPreset]()
    
    var eqUnitState: EQUnitState = EQUnitState()
    var pitchUnitState: PitchUnitState = PitchUnitState()
    var timeUnitState: TimeUnitState = TimeUnitState()
    var reverbUnitState: ReverbUnitState = ReverbUnitState()
    var delayUnitState: DelayUnitState = DelayUnitState()
    
    var filterState: EffectsUnitState = AppDefaults.filterState
    var filterBands: [FilterBand] = []
    var filterUserPresets: [FilterPreset] = []
    
    func toSerializableMap() -> NSDictionary {
        
        var map = [NSString: AnyObject]()
        
        map["volume"] = volume as NSNumber
        map["muted"] = muted as AnyObject
        map["balance"] = balance as NSNumber
        
        var masterDict = [NSString: AnyObject]()
        
        masterDict["state"] = masterState.rawValue as AnyObject
        
        // Master presets
        var masterUserPresetsArr = [[NSString: AnyObject]]()
        
        for preset in masterUserPresets {
            
            var presetDict = [NSString: AnyObject]()
            presetDict["name"] = preset.name as AnyObject
            
            // EQ preset
            var eqPresetDict = [NSString: AnyObject]()
            eqPresetDict["state"] = preset.eq.state.rawValue as AnyObject
            
            eqPresetDict["globalGain"] = preset.eq.globalGain as NSNumber
            
            var presetBandsDict = [NSString: NSNumber]()
            for (index, gain) in preset.eq.bands {
                presetBandsDict[String(index) as NSString] = gain as NSNumber
            }
            eqPresetDict["bands"] = presetBandsDict as AnyObject
            
            presetDict["eq"] = eqPresetDict as AnyObject
            
            // Pitch preset
            var pitchPresetDict = [NSString: AnyObject]()
            pitchPresetDict["state"] = preset.pitch.state.rawValue as AnyObject
            
            pitchPresetDict["pitch"] = preset.pitch.pitch as NSNumber
            pitchPresetDict["overlap"] = preset.pitch.overlap as NSNumber
            
            presetDict["pitch"] = pitchPresetDict as AnyObject
            
            // Time preset
            var timePresetDict = [NSString: AnyObject]()
            timePresetDict["state"] = preset.time.state.rawValue as AnyObject
            
            timePresetDict["rate"] = preset.time.rate as NSNumber
            timePresetDict["overlap"] = preset.time.overlap as NSNumber
            timePresetDict["shiftPitch"] = preset.time.pitchShift as AnyObject
            
            presetDict["time"] = timePresetDict as AnyObject
            
            // Reverb preset
            var reverbPresetDict = [NSString: AnyObject]()
            reverbPresetDict["state"] = preset.reverb.state.rawValue as AnyObject
            
            reverbPresetDict["space"] = preset.reverb.space.rawValue as AnyObject
            reverbPresetDict["amount"] = preset.reverb.amount as NSNumber
            
            presetDict["reverb"] = reverbPresetDict as AnyObject
            
            // Delay preset
            var delayPresetDict = [NSString: AnyObject]()
            delayPresetDict["state"] = preset.delay.state.rawValue as AnyObject
            
            delayPresetDict["amount"] = preset.delay.amount as NSNumber
            delayPresetDict["time"] = preset.delay.time as NSNumber
            delayPresetDict["feedback"] = preset.delay.feedback as NSNumber
            delayPresetDict["lowPassCutoff"] = preset.delay.cutoff as NSNumber
            
            presetDict["delay"] = delayPresetDict as AnyObject
            
            // Filter preset
            var filterPresetDict = [NSString: AnyObject]()
            filterPresetDict["state"] = preset.filter.state.rawValue as AnyObject
            
            var bandsArr = [[NSString: AnyObject]]()
            for band in preset.filter.bands {
                
                var bandDict = [NSString: AnyObject]()
                bandDict["type"] = band.type.rawValue as AnyObject
                
                if let minFreq = band.minFreq {
                    bandDict["minFreq"] = minFreq as NSNumber
                }
                
                if let maxFreq = band.maxFreq {
                    bandDict["maxFreq"] = maxFreq as NSNumber
                }
                
                bandsArr.append(bandDict)
            }
            
            filterPresetDict["bands"] = NSArray(array: bandsArr)
            
            presetDict["filter"] = filterPresetDict as AnyObject
            
            masterUserPresetsArr.append(presetDict)
        }
        
        masterDict["userPresets"] = NSArray(array: masterUserPresetsArr)
        
        map["master"] = masterDict as AnyObject
        
        map["eq"] = eqUnitState.toSerializableMap() as AnyObject
        
        map["pitch"] = pitchUnitState.toSerializableMap() as AnyObject
        
        map["time"] = timeUnitState.toSerializableMap() as AnyObject
        
        map["reverb"] = reverbUnitState.toSerializableMap() as AnyObject
        
        map["delay"] = delayUnitState.toSerializableMap() as AnyObject
        
        var filterDict = [NSString: AnyObject]()
        filterDict["state"] = filterState.rawValue as AnyObject
        
        var bandsArr = [[NSString: AnyObject]]()
        for band in filterBands {
            
            var bandDict = [NSString: AnyObject]()
            bandDict["type"] = band.type.rawValue as AnyObject
            
            if let minFreq = band.minFreq {
                bandDict["minFreq"] = minFreq as NSNumber
            }
            
            if let maxFreq = band.maxFreq {
                bandDict["maxFreq"] = maxFreq as NSNumber
            }
            
            bandsArr.append(bandDict)
        }
        
        filterDict["bands"] = NSArray(array: bandsArr)
        
        var filterUserPresetsArr = [[NSString: AnyObject]]()
        for preset in filterUserPresets {

            var presetDict = [NSString: AnyObject]()
            presetDict["name"] = preset.name as AnyObject

            var bandsArr = [[NSString: AnyObject]]()
            for band in preset.bands {
                
                var bandDict = [NSString: AnyObject]()
                bandDict["type"] = band.type.rawValue as AnyObject
                
                if let minFreq = band.minFreq {
                    bandDict["minFreq"] = minFreq as NSNumber
                }
                
                if let maxFreq = band.maxFreq {
                    bandDict["maxFreq"] = maxFreq as NSNumber
                }
                
                bandsArr.append(bandDict)
            }
            
            presetDict["bands"] = NSArray(array: bandsArr)

            filterUserPresetsArr.append(presetDict)
        }
        
        filterDict["userPresets"] = NSArray(array: filterUserPresetsArr)
        
        map["filter"] = filterDict as AnyObject
        
        return map as NSDictionary
    }
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let audioGraphState = AudioGraphState()
        
        if let volume = map["volume"] as? NSNumber {
            audioGraphState.volume = volume.floatValue
        }
        
        if let muted = map["muted"] as? Bool {
            audioGraphState.muted = muted
        }
        
        if let balance = map["balance"] as? NSNumber {
            audioGraphState.balance = balance.floatValue
        }
        
        if let masterDict = (map["master"] as? NSDictionary) {
            
            if let state = masterDict["state"] as? String {
                
                if let masterState = EffectsUnitState(rawValue: state) {
                    audioGraphState.masterState = masterState
                }
            }
            
            audioGraphState.masterUserPresets = [MasterPreset]()
            
            if let userPresets = masterDict["userPresets"] as? [NSDictionary] {
                
                userPresets.forEach({
                    
                    var presetName: String?
                    
                    if let name = $0["name"] as? String {
                        presetName = name
                    }
                    
                    var eqPreset: EQPreset = EQPresets.defaultPreset
                    
                    // EQ preset
                    if let eqDict = $0["eq"] as? NSDictionary {
                        
                        var eqPresetState: EffectsUnitState = .active
                        var eqPresetGlobalGain: Float = 0
                        var eqPresetBands: [Int: Float] = [Int: Float]()
                     
                        if let state = eqDict["state"] as? String {
                            
                            if let eqState = EffectsUnitState(rawValue: state) {
                                eqPresetState = eqState
                            }
                        }
                        
                        if let globalGain = eqDict["globalGain"] as? NSNumber {
                            eqPresetGlobalGain = globalGain.floatValue
                        }
                        
                        if let eqBands: NSDictionary = eqDict["bands"] as? NSDictionary {
                            
                            for (index, gain) in eqBands {
                                
                                if let indexStr = index as? String {
                                    
                                    if let indexInt = Int(indexStr) {
                                        
                                        if let gainNum = gain as? NSNumber {
                                            eqPresetBands[indexInt] = gainNum.floatValue
                                        }
                                    }
                                }
                            }
                        }
                        
                        eqPreset = EQPreset("", eqPresetState, eqPresetBands, eqPresetGlobalGain, false)
                    }
                    
                    var pitchPreset: PitchPreset = PitchPresets.defaultPreset
                    
                    // Pitch preset
                    
                    if let pitchDict = $0["pitch"] as? NSDictionary {
                        
                        var pitchPresetState: EffectsUnitState = .active
                        var pitchPresetPitch: Float = 0
                        var pitchPresetOverlap: Float = 0
                        
                        if let state = pitchDict["state"] as? String {
                            
                            if let pitchState = EffectsUnitState(rawValue: state) {
                                pitchPresetState = pitchState
                            }
                        }
                        
                        if let pitch = pitchDict["pitch"] as? NSNumber {
                            pitchPresetPitch = pitch.floatValue
                        }
                        
                        if let overlap = pitchDict["overlap"] as? NSNumber {
                            pitchPresetOverlap = overlap.floatValue
                        }
                    
                        pitchPreset = PitchPreset("", pitchPresetState, pitchPresetPitch, pitchPresetOverlap, false)
                    }
                    
                    var timePreset: TimePreset = TimePresets.defaultPreset
                    
                    // Time preset
                    
                    if let timeDict = $0["time"] as? NSDictionary {
                        
                        var timePresetState: EffectsUnitState = .active
                        var timePresetRate: Float = 0
                        var timePresetOverlap: Float = 0
                        var timePresetPitchShift: Bool = false
                        
                        if let state = timeDict["state"] as? String {
                            
                            if let timeState = EffectsUnitState(rawValue: state) {
                                timePresetState = timeState
                            }
                        }
                        
                        if let rate = timeDict["rate"] as? NSNumber {
                            timePresetRate = rate.floatValue
                        }
                        
                        if let shiftPitch = timeDict["shiftPitch"] as? Bool {
                            timePresetPitchShift = shiftPitch
                        }
                        
                        if let timeOverlap = timeDict["overlap"] as? NSNumber {
                            timePresetOverlap = timeOverlap.floatValue
                        }
                        
                        timePreset = TimePreset("", timePresetState, timePresetRate, timePresetOverlap, timePresetPitchShift, false)
                    }
                    
                    var reverbPreset: ReverbPreset = ReverbPreset("", AppDefaults.reverbState, AppDefaults.reverbSpace, AppDefaults.reverbAmount, false)
                    
                    // Reverb preset
                    
                    if let reverbDict = $0["reverb"] as? NSDictionary {
                        
                        var reverbPresetState: EffectsUnitState = .active
                        var reverbPresetSpace: ReverbSpaces = AppDefaults.reverbSpace
                        var reverbPresetAmount: Float = AppDefaults.reverbAmount
                    
                        if let state = reverbDict["state"] as? String {
                            
                            if let reverbState = EffectsUnitState(rawValue: state) {
                                reverbPresetState = reverbState
                            }
                        }
                        
                        if let space = reverbDict["space"] as? String {
                            
                            if let reverbSpace = ReverbSpaces(rawValue: space) {
                                reverbPresetSpace = reverbSpace
                            }
                        }
                        
                        if let amount = reverbDict["amount"] as? NSNumber {
                            reverbPresetAmount = amount.floatValue
                        }
                        
                        reverbPreset = ReverbPreset("", reverbPresetState, reverbPresetSpace, reverbPresetAmount, false)
                    }
                    
                    var delayPreset: DelayPreset = DelayPresets.defaultPreset
                    
                    // Delay preset
                    
                    if let delayDict = $0["delay"] as? NSDictionary {
                        
                        var delayPresetState: EffectsUnitState = .active
                        var delayPresetAmount: Float = AppDefaults.delayAmount
                        var delayPresetTime: Double = AppDefaults.delayTime
                        var delayPresetFeedback: Float = AppDefaults.delayFeedback
                        var delayPresetCutoff: Float = AppDefaults.delayLowPassCutoff
                        
                        if let state = delayDict["state"] as? String {
                            
                            if let delayState = EffectsUnitState(rawValue: state) {
                                delayPresetState = delayState
                            }
                        }
                        
                        if let amount = delayDict["amount"] as? NSNumber {
                            delayPresetAmount = amount.floatValue
                        }
                        
                        if let time = delayDict["time"] as? NSNumber {
                            delayPresetTime = time.doubleValue
                        }
                        
                        if let feedback = delayDict["feedback"] as? NSNumber {
                            delayPresetFeedback = feedback.floatValue
                        }
                        
                        if let cutoff = delayDict["lowPassCutoff"] as? NSNumber {
                            delayPresetCutoff = cutoff.floatValue
                        }
                        
                        delayPreset = DelayPreset("", delayPresetState, delayPresetAmount, delayPresetTime, delayPresetFeedback, delayPresetCutoff, false)
                    }
                    
                    var filterPreset: FilterPreset = FilterPresets.defaultPreset
                    
                    // Filter preset
                    
                    if let filterDict = $0["filter"] as? NSDictionary {
                        
                        var presetBands: [FilterBand] = []
                        var filterPresetState: EffectsUnitState = .active
                    
                        if let state = filterDict["state"] as? String {
                            
                            if let filterState = EffectsUnitState(rawValue: state) {
                                filterPresetState = filterState
                            }
                        }
                        
                        if let bands = filterDict["bands"] as? [NSDictionary] {
                            
                            for band in bands {
                                
                                var bandType: FilterBandType = .bandStop
                                var bandMinFreq: Float?
                                var bandMaxFreq: Float?
                                
                                if let typeStr = band["type"] as? String, let type = FilterBandType(rawValue: typeStr) {
                                    bandType = type
                                }
                                
                                if let minFreq = band["minFreq"] as? NSNumber {
                                    bandMinFreq = minFreq.floatValue
                                }
                                
                                if let maxFreq = band["maxFreq"] as? NSNumber {
                                    bandMaxFreq = maxFreq.floatValue
                                }
                                
                               presetBands.append(FilterBand(bandType, bandMinFreq, bandMaxFreq))
                            }
                        }
                        
                        filterPreset = FilterPreset("", filterPresetState, presetBands, false)
                    }
                    
                    if let presetName = presetName {
                    
                        audioGraphState.masterUserPresets.append(MasterPreset(presetName, eqPreset, pitchPreset, timePreset, reverbPreset, delayPreset, filterPreset, false))
                    }
                })
            }
        }
        
        if let eqDict = (map["eq"] as? NSDictionary) {
            // TODO: Generics :)
            audioGraphState.eqUnitState = EQUnitState.deserialize(eqDict) as! EQUnitState
        }
        
        if let pitchDict = (map["pitch"] as? NSDictionary) {
            audioGraphState.pitchUnitState = PitchUnitState.deserialize(pitchDict) as! PitchUnitState
        }
        
        if let timeDict = (map["time"] as? NSDictionary) {
            audioGraphState.timeUnitState = TimeUnitState.deserialize(timeDict) as! TimeUnitState
        }
        
        if let reverbDict = (map["reverb"] as? NSDictionary) {
            audioGraphState.reverbUnitState = ReverbUnitState.deserialize(reverbDict) as! ReverbUnitState
        }
        
        if let delayDict = (map["delay"] as? NSDictionary) {
            audioGraphState.delayUnitState = DelayUnitState.deserialize(delayDict) as! DelayUnitState
        }
        
        if let filterDict = (map["filter"] as? NSDictionary) {
            
            if let state = filterDict["state"] as? String {
                
                if let filterState = EffectsUnitState(rawValue: state) {
                    audioGraphState.filterState = filterState
                }
            }
            
            if let bands = filterDict["bands"] as? [NSDictionary] {
                
                for band in bands {
                    
                    var bandType: FilterBandType = .bandStop
                    var bandMinFreq: Float?
                    var bandMaxFreq: Float?
                    
                    if let typeStr = band["type"] as? String, let type = FilterBandType(rawValue: typeStr) {
                        bandType = type
                    }
                    
                    if let minFreq = band["minFreq"] as? NSNumber {
                        bandMinFreq = minFreq.floatValue
                    }
                    
                    if let maxFreq = band["maxFreq"] as? NSNumber {
                        bandMaxFreq = maxFreq.floatValue
                    }
                    
                    audioGraphState.filterBands.append(FilterBand(bandType, bandMinFreq, bandMaxFreq))
                }
            }
            
            // Filter user presets
            if let userPresets = filterDict["userPresets"] as? [NSDictionary] {
                
                userPresets.forEach({
                    
                    var presetName: String?
                    var presetBands: [FilterBand] = []
                    
                    if let name = $0["name"] as? String {
                        presetName = name
                    }
                    
                    if let bands = $0["bands"] as? [NSDictionary] {
                        
                        for band in bands {
                            
                            var bandType: FilterBandType = .bandStop
                            var bandMinFreq: Float?
                            var bandMaxFreq: Float?
                            
                            if let typeStr = band["type"] as? String, let type = FilterBandType(rawValue: typeStr) {
                                bandType = type
                            }
                            
                            if let minFreq = band["minFreq"] as? NSNumber {
                                bandMinFreq = minFreq.floatValue
                            }
                            
                            if let maxFreq = band["maxFreq"] as? NSNumber {
                                bandMaxFreq = maxFreq.floatValue
                            }
                            
                            presetBands.append(FilterBand(bandType, bandMinFreq, bandMaxFreq))
                        }
                    }
                    
                    // Preset must have a name
                    if let presetName = presetName {
                        audioGraphState.filterUserPresets.append(FilterPreset(presetName, .active, presetBands, false))
                    }
                })
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
    private var gapsBeforeMap: [URL: PlaybackGapState] = [:]
    private var gapsAfterMap: [URL: PlaybackGapState] = [:]
    
    func getGapsForTrack(_ track: Track) -> (gapBeforeTrack: PlaybackGapState?, gapAfterTrack: PlaybackGapState?) {
        return (gapsBeforeMap[track.file], gapsAfterMap[track.file])
    }
    
    func removeGapsForTrack(_ track: Track) {
        gapsBeforeMap.removeValue(forKey: track.file)
        gapsAfterMap.removeValue(forKey: track.file)
    }
    
    func toSerializableMap() -> NSDictionary {
        
        var map = [NSString: AnyObject]()
        
        var tracksArr = [String]()
        tracks.forEach({tracksArr.append($0.path)})
        map["tracks"] = NSArray(array: tracksArr)
        
        var gapsArr = [NSDictionary]()
        gaps.forEach({
            gapsArr.append($0.toSerializableMap())
        })
        map["gaps"] = NSArray(array: gapsArr)
        
        return map as NSDictionary
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
                    state.gapsBeforeMap[gap.track!] = gap
                } else {
                    state.gapsAfterMap[gap.track!] = gap
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
    
    func toSerializableMap() -> NSDictionary {
        
        var map = [NSString: AnyObject]()
        
        map["track"] = track!.path as AnyObject
        map["duration"] = duration as NSNumber
        map["position"] = position.rawValue as AnyObject
        map["type"] = type.rawValue as AnyObject
        
        return map as NSDictionary
    }
    
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
    
    func toSerializableMap() -> NSDictionary {
        
        var map = [NSString: AnyObject]()
        
        map["repeatMode"] = repeatMode.rawValue as AnyObject
        map["shuffleMode"] = shuffleMode.rawValue as AnyObject
        
        return map as NSDictionary
    }
    
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
    
    func toSerializableMap() -> NSDictionary {
        
        var map = [NSString: AnyObject]()
        
        var recentlyAddedArr = [NSDictionary]()
        recentlyAdded.forEach({
            recentlyAddedArr.append(self.itemToMap($0))
        })
        map["recentlyAdded"] = NSArray(array: recentlyAddedArr)
        
        var recentlyPlayedArr = [NSDictionary]()
        recentlyPlayed.forEach({
            recentlyPlayedArr.append(self.itemToMap($0))
        })
        map["recentlyPlayed"] = NSArray(array: recentlyPlayedArr)
        
        return map as NSDictionary
    }
    
    private func itemToMap(_ item: (file: URL, time: Date)) -> NSDictionary {
        
        var itemMap = [NSString: AnyObject]()
        itemMap["path"] = item.file.path as AnyObject
        itemMap["timestamp"] = item.time.serializableString() as AnyObject
        
        return itemMap as NSDictionary
    }
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = HistoryState()
        
        if let recentlyAdded = map["recentlyAdded"] as? [NSDictionary] {
            
            recentlyAdded.forEach({
                
                if let file = $0.value(forKey: "path") as? String,
                    let timestamp = $0.value(forKey: "timestamp") as? String {
                    
                    state.recentlyAdded.append((URL(fileURLWithPath: file), Date.fromString(timestamp)))
                }
            })
        }
        
        if let recentlyPlayed = map["recentlyPlayed"] as? [NSDictionary] {
            
            recentlyPlayed.forEach({
                
                if let file = $0.value(forKey: "path") as? String,
                    let timestamp = $0.value(forKey: "timestamp") as? String {
                    
                    state.recentlyPlayed.append((URL(fileURLWithPath: file), Date.fromString(timestamp)))
                }
            })
        }
        
        return state
    }
}

class FavoritesState: PersistentState {
    
    var favorites: [URL] = [URL]()
    
    func toSerializableArray() -> NSArray {
        
        var favoritesArr = [NSDictionary]()
        favorites.forEach({
            
            var map = [NSString: AnyObject]()
            map["file"] = $0.path as AnyObject
            
            favoritesArr.append(map as NSDictionary)
        })
        
        return NSArray(array: favoritesArr)
    }
    
    static func deserialize(_ array: NSArray) -> PersistentState {
        
        let state = FavoritesState()
        
        array.forEach({
            
            if let favoriteMap = $0 as? NSDictionary {
                
                if let file = favoriteMap.value(forKey: "file") as? String {
                    state.favorites.append(URL(fileURLWithPath: file))
                }
            }
        })
        
        return state
    }
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        // NOT USED
        return FavoritesState()
    }
}

class BookmarksState: PersistentState {
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        // NOT USED
        return BookmarksState()
    }
    
    var bookmarks: [(name: String, file: URL, startPosition: Double, endPosition: Double?)] = [(name: String, file: URL, startPosition: Double, endPosition: Double?)]()
    
    func toSerializableArray() -> NSArray {
        
        var bookmarksArr = [NSDictionary]()
        bookmarks.forEach({
            
            var map = [NSString: AnyObject]()
            map["name"] = $0.name as AnyObject
            map["file"] = $0.file.path as AnyObject
            map["startPosition"] = $0.startPosition as NSNumber
            
            if let endPos = $0.endPosition {
                map["endPosition"] = endPos as NSNumber
            }
            
            bookmarksArr.append(map as NSDictionary)
        })
        
        return NSArray(array: bookmarksArr)
    }
    
    static func deserialize(_ arr: NSArray) -> PersistentState {
        
        let state = BookmarksState()
        
        arr.forEach({
        
            if let bookmarkMap = $0 as? NSDictionary {
                
                if let name = bookmarkMap.value(forKey: "name") as? String,
                    let file = bookmarkMap.value(forKey: "file") as? String,
                    let startPosition = bookmarkMap.value(forKey: "startPosition") as? NSNumber {
                    
                    if let endPosition = bookmarkMap.value(forKey: "endPosition") as? NSNumber {
                        state.bookmarks.append((name, URL(fileURLWithPath: file), startPosition.doubleValue, endPosition.doubleValue))
                    } else {
                        state.bookmarks.append((name, URL(fileURLWithPath: file), startPosition.doubleValue, nil))
                    }
                }
            }
        })
        
        return state
    }
}

class SoundProfilesState: PersistentState {
    
    var profiles: [SoundProfile] = []
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        // NOT USED
        return SoundProfilesState()
    }
    
    func toSerializableArray() -> NSArray {
        
        var profilesArr = [NSDictionary]()
        profiles.forEach({
            
            var map = [NSString: AnyObject]()
            
            map["file"] = $0.file.path as AnyObject
            
            map["volume"] = $0.volume as NSNumber
            map["balance"] = $0.balance as NSNumber
            
            // Effects
            
            let effects = $0.effects
            var effectsDict = [NSString: AnyObject]()
            
            // EQ
            var eqDict = [NSString: AnyObject]()
            eqDict["state"] = effects.eq.state.rawValue as AnyObject
            
            eqDict["globalGain"] = effects.eq.globalGain as NSNumber
            
            var bandsDict = [NSString: NSNumber]()
            for (index, gain) in effects.eq.bands {
                bandsDict[String(index) as NSString] = gain as NSNumber
            }
            eqDict["bands"] = bandsDict as AnyObject
            
            effectsDict["eq"] = eqDict as AnyObject
            
            // Pitch
            var pitchDict = [NSString: AnyObject]()
            pitchDict["state"] = effects.pitch.state.rawValue as AnyObject
            
            pitchDict["pitch"] = effects.pitch.pitch as NSNumber
            pitchDict["overlap"] = effects.pitch.overlap as NSNumber
            
            effectsDict["pitch"] = pitchDict as AnyObject
            
            // Time
            var timeDict = [NSString: AnyObject]()
            timeDict["state"] = effects.time.state.rawValue as AnyObject
            
            timeDict["rate"] = effects.time.rate as NSNumber
            timeDict["overlap"] = effects.time.overlap as NSNumber
            timeDict["shiftPitch"] = effects.time.pitchShift as AnyObject
            
            effectsDict["time"] = timeDict as AnyObject
            
            // Reverb
            var reverbDict = [NSString: AnyObject]()
            reverbDict["state"] = effects.reverb.state.rawValue as AnyObject
            
            reverbDict["space"] = effects.reverb.space.rawValue as AnyObject
            reverbDict["amount"] = effects.reverb.amount as NSNumber
            
            effectsDict["reverb"] = reverbDict as AnyObject
            
            // Delay
            var delayDict = [NSString: AnyObject]()
            delayDict["state"] = effects.delay.state.rawValue as AnyObject
            
            delayDict["amount"] = effects.delay.amount as NSNumber
            delayDict["time"] = effects.delay.time as NSNumber
            delayDict["feedback"] = effects.delay.feedback as NSNumber
            delayDict["lowPassCutoff"] = effects.delay.cutoff as NSNumber
            
            effectsDict["delay"] = delayDict as AnyObject
            
            // Filter
            var filterDict = [NSString: AnyObject]()
            filterDict["state"] = effects.filter.state.rawValue as AnyObject
            
            var bandsArr = [[NSString: AnyObject]]()
            for band in effects.filter.bands {
                
                var bandDict = [NSString: AnyObject]()
                bandDict["type"] = band.type.rawValue as AnyObject
                
                if let minFreq = band.minFreq {
                    bandDict["minFreq"] = minFreq as NSNumber
                }
                
                if let maxFreq = band.maxFreq {
                    bandDict["maxFreq"] = maxFreq as NSNumber
                }
                
                bandsArr.append(bandDict)
            }
            
            filterDict["bands"] = NSArray(array: bandsArr)
            
            effectsDict["filter"] = filterDict as AnyObject
            
            map["effects"] = effectsDict as AnyObject
            
            profilesArr.append(map as NSDictionary)
        })
        
        return NSArray(array: profilesArr)
    }
    
    static func deserialize(_ arr: NSArray) -> PersistentState {
        
        let state = SoundProfilesState()
        
        arr.forEach({
            
            let map = $0 as! NSDictionary
            
            var profileFile: URL?
            var profileVolume: Float = AppDefaults.volume
            var profileBalance: Float = AppDefaults.balance
            
            if let file = map["file"] as? String {
                profileFile = URL(fileURLWithPath: file)
            }
            
            if let volume = map["volume"] as? NSNumber {
                profileVolume = volume.floatValue
            }
            
            if let balance = map["balance"] as? NSNumber {
                profileBalance = balance.floatValue
            }
            
            if let effectsDict = (map["effects"] as? NSDictionary) {
                
                var eqPreset: EQPreset = EQPresets.defaultPreset
                
                // EQ preset
                if let eqDict = effectsDict["eq"] as? NSDictionary {
                    
                    var eqPresetState: EffectsUnitState = .active
                    var eqPresetGlobalGain: Float = 0
                    var eqPresetBands: [Int: Float] = [Int: Float]()
                    
                    if let state = eqDict["state"] as? String {
                        
                        if let eqState = EffectsUnitState(rawValue: state) {
                            eqPresetState = eqState
                        }
                    }
                    
                    if let globalGain = eqDict["globalGain"] as? NSNumber {
                        eqPresetGlobalGain = globalGain.floatValue
                    }
                    
                    if let eqBands: NSDictionary = eqDict["bands"] as? NSDictionary {
                        
                        for (index, gain) in eqBands {
                            
                            if let indexStr = index as? String {
                                
                                if let indexInt = Int(indexStr) {
                                    
                                    if let gainNum = gain as? NSNumber {
                                        eqPresetBands[indexInt] = gainNum.floatValue
                                    }
                                }
                            }
                        }
                    }
                    
                    eqPreset = EQPreset("", eqPresetState, eqPresetBands, eqPresetGlobalGain, false)
                }
                
                var pitchPreset: PitchPreset = PitchPresets.defaultPreset
                
                // Pitch preset
                
                if let pitchDict = effectsDict["pitch"] as? NSDictionary {
                    
                    var pitchPresetState: EffectsUnitState = .active
                    var pitchPresetPitch: Float = 0
                    var pitchPresetOverlap: Float = 0
                    
                    if let state = pitchDict["state"] as? String {
                        
                        if let pitchState = EffectsUnitState(rawValue: state) {
                            pitchPresetState = pitchState
                        }
                    }
                    
                    if let pitch = pitchDict["pitch"] as? NSNumber {
                        pitchPresetPitch = pitch.floatValue
                    }
                    
                    if let overlap = pitchDict["overlap"] as? NSNumber {
                        pitchPresetOverlap = overlap.floatValue
                    }
                    
                    pitchPreset = PitchPreset("", pitchPresetState, pitchPresetPitch, pitchPresetOverlap, false)
                }
                
                var timePreset: TimePreset = TimePresets.defaultPreset
                
                // Time preset
                
                if let timeDict = effectsDict["time"] as? NSDictionary {
                    
                    var timePresetState: EffectsUnitState = .active
                    var timePresetRate: Float = 0
                    var timePresetOverlap: Float = 0
                    var timePresetPitchShift: Bool = false
                    
                    if let state = timeDict["state"] as? String {
                        
                        if let timeState = EffectsUnitState(rawValue: state) {
                            timePresetState = timeState
                        }
                    }
                    
                    if let rate = timeDict["rate"] as? NSNumber {
                        timePresetRate = rate.floatValue
                    }
                    
                    if let shiftPitch = timeDict["shiftPitch"] as? Bool {
                        timePresetPitchShift = shiftPitch
                    }
                    
                    if let timeOverlap = timeDict["overlap"] as? NSNumber {
                        timePresetOverlap = timeOverlap.floatValue
                    }
                    
                    timePreset = TimePreset("", timePresetState, timePresetRate, timePresetOverlap, timePresetPitchShift, false)
                }
                
                var reverbPreset: ReverbPreset = ReverbPreset("", AppDefaults.reverbState, AppDefaults.reverbSpace, AppDefaults.reverbAmount, false)
                
                // Reverb preset
                
                if let reverbDict = effectsDict["reverb"] as? NSDictionary {
                    
                    var reverbPresetState: EffectsUnitState = .active
                    var reverbPresetSpace: ReverbSpaces = AppDefaults.reverbSpace
                    var reverbPresetAmount: Float = AppDefaults.reverbAmount
                    
                    if let state = reverbDict["state"] as? String {
                        
                        if let reverbState = EffectsUnitState(rawValue: state) {
                            reverbPresetState = reverbState
                        }
                    }
                    
                    if let space = reverbDict["space"] as? String {
                        
                        if let reverbSpace = ReverbSpaces(rawValue: space) {
                            reverbPresetSpace = reverbSpace
                        }
                    }
                    
                    if let amount = reverbDict["amount"] as? NSNumber {
                        reverbPresetAmount = amount.floatValue
                    }
                    
                    reverbPreset = ReverbPreset("", reverbPresetState, reverbPresetSpace, reverbPresetAmount, false)
                }
                
                var delayPreset: DelayPreset = DelayPresets.defaultPreset
                
                // Delay preset
                
                if let delayDict = effectsDict["delay"] as? NSDictionary {
                    
                    var delayPresetState: EffectsUnitState = .active
                    var delayPresetAmount: Float = AppDefaults.delayAmount
                    var delayPresetTime: Double = AppDefaults.delayTime
                    var delayPresetFeedback: Float = AppDefaults.delayFeedback
                    var delayPresetCutoff: Float = AppDefaults.delayLowPassCutoff
                    
                    if let state = delayDict["state"] as? String {
                        
                        if let delayState = EffectsUnitState(rawValue: state) {
                            delayPresetState = delayState
                        }
                    }
                    
                    if let amount = delayDict["amount"] as? NSNumber {
                        delayPresetAmount = amount.floatValue
                    }
                    
                    if let time = delayDict["time"] as? NSNumber {
                        delayPresetTime = time.doubleValue
                    }
                    
                    if let feedback = delayDict["feedback"] as? NSNumber {
                        delayPresetFeedback = feedback.floatValue
                    }
                    
                    if let cutoff = delayDict["lowPassCutoff"] as? NSNumber {
                        delayPresetCutoff = cutoff.floatValue
                    }
                    
                    delayPreset = DelayPreset("", delayPresetState, delayPresetAmount, delayPresetTime, delayPresetFeedback, delayPresetCutoff, false)
                }
                
                var filterPreset: FilterPreset = FilterPresets.defaultPreset
                
                // Filter preset
                
                if let filterDict = effectsDict["filter"] as? NSDictionary {

                    var filterPresetState: EffectsUnitState = .active
                    var presetBands: [FilterBand] = []
                    
                    if let state = filterDict["state"] as? String {
                        
                        if let filterState = EffectsUnitState(rawValue: state) {
                            filterPresetState = filterState
                        }
                    }
                    
                    if let bands = filterDict["bands"] as? [NSDictionary] {
                        
                        for band in bands {
                            
                            var bandType: FilterBandType = .bandStop
                            var bandMinFreq: Float?
                            var bandMaxFreq: Float?
                            
                            if let typeStr = band["type"] as? String, let type = FilterBandType(rawValue: typeStr) {
                                bandType = type
                            }
                            
                            if let minFreq = band["minFreq"] as? NSNumber {
                                bandMinFreq = minFreq.floatValue
                            }
                            
                            if let maxFreq = band["maxFreq"] as? NSNumber {
                                bandMaxFreq = maxFreq.floatValue
                            }
                            
                            presetBands.append(FilterBand(bandType, bandMinFreq, bandMaxFreq))
                        }
                    }
                    
                    filterPreset = FilterPreset("", filterPresetState, presetBands, false)
                }
                
                let effects = MasterPreset("masterPreset_for_soundProfile", eqPreset, pitchPreset, timePreset, reverbPreset, delayPreset, filterPreset, false)
                
                state.profiles.append(SoundProfile(file: profileFile!, volume: profileVolume, balance: profileBalance, effects: effects))
            }
        })
        
        return state
    }
}

class PlaybackProfilesState: PersistentState {
    
    var profiles: [PlaybackProfile] = []
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        // NOT USED
        return PlaybackProfilesState()
    }
    
    func toSerializableArray() -> NSArray {
        
        var profilesArr = [NSDictionary]()
        profiles.forEach({
            
            var map = [NSString: AnyObject]()
            
            map["file"] = $0.file.path as AnyObject
            map["lastPosition"] = $0.lastPosition as NSNumber
            
            profilesArr.append(map as NSDictionary)
        })
        
        return NSArray(array: profilesArr)
    }
    
    static func deserialize(_ arr: NSArray) -> PersistentState {
        
        let state = PlaybackProfilesState()
        
        arr.forEach({
            
            let map = $0 as! NSDictionary
            
            var profileFile: URL?
            var profileLastPosition: Double = AppDefaults.lastTrackPosition
            
            if let file = map["file"] as? String {
                profileFile = URL(fileURLWithPath: file)
            }
            
            if let posn = map["lastPosition"] as? NSNumber {
                profileLastPosition = posn.doubleValue
            }
            
            let profile = PlaybackProfile(profileFile!)
            profile.lastPosition = profileLastPosition
            state.profiles.append(profile)
        })
        
        return state
    }
}

/*
 Encapsulates all application state. It is persisted to disk upon exit and loaded into the application upon startup.
 
 TODO: Make this class conform to different protocols for access/mutation
 */
class AppState {
    
    var uiState: UIState
    var audioGraphState: AudioGraphState
    var playlistState: PlaylistState
    var playbackSequenceState: PlaybackSequenceState
    var historyState: HistoryState
    var favoritesState: FavoritesState
    var bookmarksState: BookmarksState
    var soundProfilesState: SoundProfilesState
    var playbackProfilesState: PlaybackProfilesState
    
    static let defaults: AppState = AppState()
    
    private init() {
        
        self.uiState = UIState()
        self.audioGraphState = AudioGraphState()
        self.playlistState = PlaylistState()
        self.playbackSequenceState = PlaybackSequenceState()
        self.historyState = HistoryState()
        self.favoritesState = FavoritesState()
        self.bookmarksState = BookmarksState()
        self.soundProfilesState = SoundProfilesState()
        self.playbackProfilesState = PlaybackProfilesState()
    }
    
    init(_ uiState: UIState, _ audioGraphState: AudioGraphState, _ playlistState: PlaylistState, _ playbackSequenceState: PlaybackSequenceState, _ historyState: HistoryState, _ favoritesState: FavoritesState, _ bookmarksState: BookmarksState, _ soundProfilesState: SoundProfilesState, _ playbackProfilesState: PlaybackProfilesState) {
        
        self.uiState = uiState
        self.audioGraphState = audioGraphState
        self.playlistState = playlistState
        self.playbackSequenceState = playbackSequenceState
        self.historyState = historyState
        self.favoritesState = favoritesState
        self.bookmarksState = bookmarksState
        self.soundProfilesState = soundProfilesState
        self.playbackProfilesState = playbackProfilesState
    }
    
    // Produces an equivalent object suitable for serialization as JSON
    func toSerializableMap() -> NSDictionary {
        
        var dict = [NSString: AnyObject]()
        
        dict["ui"] = uiState.toSerializableMap() as AnyObject
        dict["audioGraph"] = audioGraphState.toSerializableMap() as AnyObject
        dict["playbackSequence"] = playbackSequenceState.toSerializableMap() as AnyObject
        dict["playlist"] = playlistState.toSerializableMap() as AnyObject
        dict["history"] = historyState.toSerializableMap() as AnyObject
        dict["favorites"] = favoritesState.toSerializableArray() as AnyObject
        dict["bookmarks"] = bookmarksState.toSerializableArray() as AnyObject
        dict["soundProfiles"] = soundProfilesState.toSerializableArray() as AnyObject
        dict["playbackProfiles"] = playbackProfilesState.toSerializableArray() as AnyObject
        
        return dict as NSDictionary
    }
    
    // Produces an AppState object from deserialized JSON
    static func deserialize(_ jsonObject: NSDictionary) -> AppState {
        
        let state = AppState()
        
        if let uiDict = (jsonObject["ui"] as? NSDictionary) {
            state.uiState = UIState.deserialize(uiDict) as! UIState
        }
        
        if let map = (jsonObject["audioGraph"] as? NSDictionary) {
            state.audioGraphState = AudioGraphState.deserialize(map) as! AudioGraphState
        }
        
        if let playbackSequenceDict = (jsonObject["playbackSequence"] as? NSDictionary) {
            state.playbackSequenceState = PlaybackSequenceState.deserialize(playbackSequenceDict) as! PlaybackSequenceState
        }
        
        if let playlistDict = (jsonObject["playlist"] as? NSDictionary) {
            state.playlistState = PlaylistState.deserialize(playlistDict) as! PlaylistState
        }
        
        if let historyDict = (jsonObject["history"] as? NSDictionary) {
            state.historyState = HistoryState.deserialize(historyDict) as! HistoryState
        }
        
        if let favoritesDict = (jsonObject["favorites"] as? NSArray) {
            state.favoritesState = FavoritesState.deserialize(favoritesDict) as! FavoritesState
        }
        
        if let bookmarksArr = (jsonObject["bookmarks"] as? NSArray) {
            state.bookmarksState = BookmarksState.deserialize(bookmarksArr) as! BookmarksState
        }
        
        if let soundProfilesArr = (jsonObject["soundProfiles"] as? NSArray) {
            state.soundProfilesState = SoundProfilesState.deserialize(soundProfilesArr) as! SoundProfilesState
        }
        
        if let playbackProfilesArr = (jsonObject["playbackProfiles"] as? NSArray) {
            state.playbackProfilesState = PlaybackProfilesState.deserialize(playbackProfilesArr) as! PlaybackProfilesState
        }
        
        return state
    }
}
