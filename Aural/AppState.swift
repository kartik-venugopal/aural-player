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
    
    var showEffects: Bool = true
    var showPlaylist: Bool = true
    
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
        
        if (showEffects) {
            map["effectsWindow_x"] = effectsWindowOrigin!.x as NSNumber
            map["effectsWindow_y"] = effectsWindowOrigin!.y as NSNumber
        }
        
        if (showPlaylist) {
            map["playlistWindow_x"] = playlistWindowFrame!.origin.x as NSNumber
            map["playlistWindow_y"] = playlistWindowFrame!.origin.y as NSNumber
            map["playlistWindow_width"] = playlistWindowFrame!.width as NSNumber
            map["playlistWindow_height"] = playlistWindowFrame!.height as NSNumber
        }
        
        var userWindowLayoutsArr = [[NSString: AnyObject]]()
        for layout in userWindowLayouts {
            
            var layoutDict = [NSString: AnyObject]()
            
            layoutDict["name"] = layout.name as AnyObject
            
            layoutDict["showPlaylist"] = layout.showPlaylist as AnyObject
            layoutDict["showEffects"] = layout.showEffects as AnyObject
            
            layoutDict["mainWindow_x"] = layout.mainWindowOrigin.x as NSNumber
            layoutDict["mainWindow_y"] = layout.mainWindowOrigin.y as NSNumber
            
            if (layout.showEffects) {
                layoutDict["effectsWindow_x"] = layout.effectsWindowOrigin!.x as NSNumber
                layoutDict["effectsWindow_y"] = layout.effectsWindowOrigin!.y as NSNumber
            }
            
            if (layout.showPlaylist) {
                layoutDict["playlistWindow_x"] = layout.playlistWindowFrame!.origin.x as NSNumber
                layoutDict["playlistWindow_y"] = layout.playlistWindowFrame!.origin.y as NSNumber
                layoutDict["playlistWindow_width"] = layout.playlistWindowFrame!.width as NSNumber
                layoutDict["playlistWindow_height"] = layout.playlistWindowFrame!.height as NSNumber
            }
            
            userWindowLayoutsArr.append(layoutDict)
        }
        
        map["userLayouts"] = NSArray(array: userWindowLayoutsArr)
        
        return map as NSDictionary
    }
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let uiState = UIState()
        
        if let showPlaylist = map["showPlaylist"] as? Bool {
            uiState.showPlaylist = showPlaylist
        }
        
        if let showEffects = map["showEffects"] as? Bool {
            uiState.showEffects = showEffects
        }
        
        if let mainWindowX = map["mainWindow_x"] as? NSNumber {
            
            if let mainWindowY = map["mainWindow_y"] as? NSNumber {
                uiState.mainWindowOrigin = NSPoint(x: CGFloat(mainWindowX.floatValue), y: CGFloat(mainWindowY.floatValue))
            }
        }

        if uiState.showEffects {
            
            if let effectsWindowX = map["effectsWindow_x"] as? NSNumber {
                
                if let effectsWindowY = map["effectsWindow_y"] as? NSNumber {
                    
                    uiState.effectsWindowOrigin = NSPoint(x: CGFloat(effectsWindowX.floatValue), y: CGFloat(effectsWindowY.floatValue))
                }
            }
        }
        
        if uiState.showPlaylist {
            
            if let playlistWindowX = map["playlistWindow_x"] as? NSNumber {
                
                if let playlistWindowY = map["playlistWindow_y"] as? NSNumber {
                    
                    let origin  = NSPoint(x: CGFloat(playlistWindowX.floatValue), y: CGFloat(playlistWindowY.floatValue))
                    
                    if let playlistWindowWidth = map["playlistWindow_width"] as? NSNumber {
                        
                        if let playlistWindowHeight = map["playlistWindow_height"] as? NSNumber {
                            
                            uiState.playlistWindowFrame = NSRect(x: origin.x, y: origin.y, width: CGFloat(playlistWindowWidth.floatValue), height: CGFloat(playlistWindowHeight.floatValue))
                        }
                    }
                }
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
                
                if let showingEffects = layoutShowEffects {
                    
                    if showingEffects {
                        
                        if let effectsWindowX = layout["effectsWindow_x"] as? NSNumber {
                            
                            if let effectsWindowY = layout["effectsWindow_y"] as? NSNumber {
                                
                                layoutEffectsWindowOrigin = NSPoint(x: CGFloat(effectsWindowX.floatValue), y: CGFloat(effectsWindowY.floatValue))
                            }
                        }
                    }
                }
                
                if let showingPlaylist = layoutShowPlaylist {
                    
                    if showingPlaylist {
                        
                        if let playlistWindowX = layout["playlistWindow_x"] as? NSNumber {
                            
                            if let playlistWindowY = layout["playlistWindow_y"] as? NSNumber {
                                
                                let origin  = NSPoint(x: CGFloat(playlistWindowX.floatValue), y: CGFloat(playlistWindowY.floatValue))
                                
                                if let playlistWindowWidth = layout["playlistWindow_width"] as? NSNumber {
                                    
                                    if let playlistWindowHeight = layout["playlistWindow_height"] as? NSNumber {
                                        
                                        layoutPlaylistWindowFrame = NSRect(x: origin.x, y: origin.y, width: CGFloat(playlistWindowWidth.floatValue), height: CGFloat(playlistWindowHeight.floatValue))
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Make sure you have all the required info
                if layoutName != nil && layoutShowEffects != nil && layoutShowPlaylist != nil && layoutMainWindowOrigin != nil {
                    
                    if ((layoutShowEffects! && layoutEffectsWindowOrigin != nil) || !layoutShowEffects!) {
                        
                        if ((layoutShowPlaylist! && layoutPlaylistWindowFrame != nil) || !layoutShowPlaylist!) {
                            
                            let newLayout = WindowLayout(layoutName!, layoutShowEffects!, layoutShowPlaylist!, layoutMainWindowOrigin!, layoutEffectsWindowOrigin, layoutPlaylistWindowFrame, false)
                            
                            uiState.userWindowLayouts.append(newLayout)
                        }
                    }
                }
            })
        }
        
        return uiState
    }
}

/*
 Encapsulates audio graph state
 */
class AudioGraphState: PersistentState {
    
    var volume: Float = AppDefaults.volume
    var muted: Bool = AppDefaults.muted
    var balance: Float = AppDefaults.balance
    
    var masterBypass: Bool = AppDefaults.masterBypass
    
    var eqState: EffectsUnitState = AppDefaults.eqState
    var eqGlobalGain: Float = AppDefaults.eqGlobalGain
    var eqBands: [Int: Float] = [Int: Float]() // Index -> Gain
    var eqUserPresets: [EQPreset] = [EQPreset]()
    
    var pitchState: EffectsUnitState = AppDefaults.pitchState
    var pitch: Float = AppDefaults.pitch
    var pitchOverlap: Float = AppDefaults.pitchOverlap
    var pitchUserPresets: [PitchPreset] = [PitchPreset]()
    
    var timeState: EffectsUnitState = AppDefaults.timeState
    var timeStretchRate: Float = AppDefaults.timeStretchRate
    var timeShiftPitch: Bool = AppDefaults.timeShiftPitch
    var timeOverlap: Float = AppDefaults.timeOverlap
    var timeUserPresets: [TimePreset] = [TimePreset]()
    
    var reverbState: EffectsUnitState = AppDefaults.reverbState
    var reverbSpace: ReverbSpaces = AppDefaults.reverbSpace
    var reverbAmount: Float = AppDefaults.reverbAmount
    var reverbUserPresets: [ReverbPreset] = [ReverbPreset]()
    
    var delayState: EffectsUnitState = AppDefaults.delayState
    var delayAmount: Float = AppDefaults.delayAmount
    var delayTime: Double = AppDefaults.delayTime
    var delayFeedback: Float = AppDefaults.delayFeedback
    var delayLowPassCutoff: Float = AppDefaults.delayLowPassCutoff
    var delayUserPresets: [DelayPreset] = [DelayPreset]()
    
    var filterState: EffectsUnitState = AppDefaults.filterState
    var filterBassMin: Float = AppDefaults.filterBassMin
    var filterBassMax: Float = AppDefaults.filterBassMax
    var filterMidMin: Float = AppDefaults.filterMidMin
    var filterMidMax: Float = AppDefaults.filterMidMax
    var filterTrebleMin: Float = AppDefaults.filterTrebleMin
    var filterTrebleMax: Float = AppDefaults.filterTrebleMax
    var filterUserPresets: [FilterPreset] = [FilterPreset]()
    
    func toSerializableMap() -> NSDictionary {
        
        var map = [NSString: AnyObject]()
        
        map["volume"] = volume as NSNumber
        map["muted"] = muted as AnyObject
        map["balance"] = balance as NSNumber
        
        map["masterBypass"] = masterBypass as AnyObject
        
        var eqDict = [NSString: AnyObject]()
        eqDict["state"] = eqState.rawValue as AnyObject
        eqDict["globalGain"] = eqGlobalGain as NSNumber
        
        var eqBandsDict = [NSString: NSNumber]()
        for (index, gain) in eqBands {
            eqBandsDict[String(index) as NSString] = gain as NSNumber
        }
        eqDict["bands"] = eqBandsDict as AnyObject
        
        var eqUserPresetsArr = [[NSString: AnyObject]]()
        for preset in eqUserPresets {
            
            var presetDict = [NSString: AnyObject]()
            presetDict["name"] = preset.name as AnyObject
            
            var presetBandsDict = [NSString: NSNumber]()
            for (index, gain) in preset.bands {
                presetBandsDict[String(index) as NSString] = gain as NSNumber
            }
            presetDict["bands"] = presetBandsDict as AnyObject
            
            eqUserPresetsArr.append(presetDict)
        }
        eqDict["userPresets"] = NSArray(array: eqUserPresetsArr)
        
        map["eq"] = eqDict as AnyObject
        
        var pitchDict = [NSString: AnyObject]()
        pitchDict["state"] = pitchState.rawValue as AnyObject
        pitchDict["pitch"] = pitch as NSNumber
        pitchDict["overlap"] = pitchOverlap as NSNumber
        
        var pitchUserPresetsArr = [[NSString: AnyObject]]()
        for preset in pitchUserPresets {
            
            var presetDict = [NSString: AnyObject]()
            presetDict["name"] = preset.name as AnyObject
            presetDict["pitch"] = preset.pitch as NSNumber
            presetDict["overlap"] = preset.overlap as NSNumber
            
            pitchUserPresetsArr.append(presetDict)
        }
        pitchDict["userPresets"] = NSArray(array: pitchUserPresetsArr)
        
        map["pitch"] = pitchDict as AnyObject
        
        var timeDict = [NSString: AnyObject]()
        timeDict["state"] = timeState.rawValue as AnyObject
        timeDict["rate"] = timeStretchRate as NSNumber
        timeDict["shiftPitch"] = timeShiftPitch as AnyObject
        timeDict["overlap"] = timeOverlap as NSNumber
        
        var timeUserPresetsArr = [[NSString: AnyObject]]()
        for preset in timeUserPresets {
            
            var presetDict = [NSString: AnyObject]()
            presetDict["name"] = preset.name as AnyObject
            presetDict["rate"] = preset.rate as NSNumber
            presetDict["overlap"] = preset.overlap as NSNumber
            presetDict["shiftPitch"] = preset.pitchShift as AnyObject
            
            timeUserPresetsArr.append(presetDict)
        }
        timeDict["userPresets"] = NSArray(array: timeUserPresetsArr)
        
        map["time"] = timeDict as AnyObject
        
        var reverbDict = [NSString: AnyObject]()
        reverbDict["state"] = reverbState.rawValue as AnyObject
        reverbDict["space"] = reverbSpace.rawValue as AnyObject
        reverbDict["amount"] = reverbAmount as NSNumber
        
        var reverbUserPresetsArr = [[NSString: AnyObject]]()
        for preset in reverbUserPresets {
            
            var presetDict = [NSString: AnyObject]()
            presetDict["name"] = preset.name as AnyObject
            presetDict["space"] = preset.space.rawValue as AnyObject
            presetDict["amount"] = preset.amount as NSNumber
            
            reverbUserPresetsArr.append(presetDict)
        }
        reverbDict["userPresets"] = NSArray(array: reverbUserPresetsArr)
        
        map["reverb"] = reverbDict as AnyObject
        
        var delayDict = [NSString: AnyObject]()
        delayDict["state"] = delayState.rawValue as AnyObject
        delayDict["amount"] = delayAmount as NSNumber
        delayDict["time"] = delayTime as NSNumber
        delayDict["feedback"] = delayFeedback as NSNumber
        delayDict["lowPassCutoff"] = delayLowPassCutoff as NSNumber
        
        var delayUserPresetsArr = [[NSString: AnyObject]]()
        for preset in delayUserPresets {
            
            var presetDict = [NSString: AnyObject]()
            presetDict["name"] = preset.name as AnyObject
            presetDict["amount"] = preset.amount as NSNumber
            presetDict["time"] = preset.time as NSNumber
            presetDict["feedback"] = preset.feedback as NSNumber
            presetDict["lowPassCutoff"] = preset.cutoff as NSNumber
            
            delayUserPresetsArr.append(presetDict)
        }
        delayDict["userPresets"] = NSArray(array: delayUserPresetsArr)
        
        map["delay"] = delayDict as AnyObject
        
        var filterDict = [NSString: AnyObject]()
        filterDict["state"] = filterState.rawValue as AnyObject
        filterDict["bassMin"] = filterBassMin as NSNumber
        filterDict["bassMax"] = filterBassMax as NSNumber
        filterDict["midMin"] = filterMidMin as NSNumber
        filterDict["midMax"] = filterMidMax as NSNumber
        filterDict["trebleMin"] = filterTrebleMin as NSNumber
        filterDict["trebleMax"] = filterTrebleMax as NSNumber
        
        var filterUserPresetsArr = [[NSString: AnyObject]]()
        for preset in filterUserPresets {
            
            var presetDict = [NSString: AnyObject]()
            presetDict["name"] = preset.name as AnyObject
            
            presetDict["bassMin"] = preset.bassBand.lowerBound as NSNumber
            presetDict["bassMax"] = preset.bassBand.upperBound as NSNumber
            
            presetDict["midMin"] = preset.midBand.lowerBound as NSNumber
            presetDict["midMax"] = preset.midBand.upperBound as NSNumber
            
            presetDict["trebleMin"] = preset.trebleBand.lowerBound as NSNumber
            presetDict["trebleMax"] = preset.trebleBand.upperBound as NSNumber
            
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
        
        if let bypass = map["masterBypass"] as? Bool {
            audioGraphState.masterBypass = bypass
        }
        
        if let eqDict = (map["eq"] as? NSDictionary) {
            
            if let state = eqDict["state"] as? String {
                if let eqState = EffectsUnitState(rawValue: state) {
                    audioGraphState.eqState = eqState
                }
            }
            
            if let globalGain = eqDict["globalGain"] as? NSNumber {
                audioGraphState.eqGlobalGain = globalGain.floatValue
            }
            
            if let eqBands: NSDictionary = eqDict["bands"] as? NSDictionary {
                
                for (index, gain) in eqBands {
                    
                    if let indexStr = index as? String {
                        
                        if let indexInt = Int(indexStr) {
                            
                            if let gainNum = gain as? NSNumber {
                                audioGraphState.eqBands[indexInt] = gainNum.floatValue
                            }
                        }
                    }
                }
            }
            
            // EQ User presets
            if let userPresets = eqDict["userPresets"] as? [NSDictionary] {
                
                userPresets.forEach({
                    
                    var presetName: String?
                    
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
                    
                    // Preset must have a name
                    if let presetName = presetName {
                        audioGraphState.eqUserPresets.append(EQPreset(name: presetName, bands: presetBands, systemDefined: false))
                    }
                })
            }
        }
        
        if let pitchDict = (map["pitch"] as? NSDictionary) {
            
            if let state = pitchDict["state"] as? String {
                if let pitchState = EffectsUnitState(rawValue: state) {
                    audioGraphState.pitchState = pitchState
                }
            }
            
            if let pitch = pitchDict["pitch"] as? NSNumber {
                audioGraphState.pitch = pitch.floatValue
            }
            
            if let overlap = pitchDict["overlap"] as? NSNumber {
                audioGraphState.pitchOverlap = overlap.floatValue
            }
            
            // Pitch user presets
            if let userPresets = pitchDict["userPresets"] as? [NSDictionary] {
                
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
                        audioGraphState.pitchUserPresets.append(PitchPreset(name: presetName, pitch: presetPitch!, overlap: presetOverlap!, systemDefined: false))
                    }
                })
            }
        }
        
        if let timeDict = (map["time"] as? NSDictionary) {
            
            if let state = timeDict["state"] as? String {
                if let timeState = EffectsUnitState(rawValue: state) {
                    audioGraphState.timeState = timeState
                }
            }
            
            if let rate = timeDict["rate"] as? NSNumber {
                audioGraphState.timeStretchRate = rate.floatValue
            }
            
            if let shiftPitch = timeDict["shiftPitch"] as? Bool {
                audioGraphState.timeShiftPitch = shiftPitch
            }
            
            if let timeOverlap = timeDict["overlap"] as? NSNumber {
                audioGraphState.timeOverlap = timeOverlap.floatValue
            }
            
            // Time user presets
            if let userPresets = timeDict["userPresets"] as? [NSDictionary] {
                
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
                        audioGraphState.timeUserPresets.append(TimePreset(name: presetName, rate: presetRate!, overlap: presetOverlap!, pitchShift: presetPitchShift!, systemDefined: false))
                    }
                })
            }
        }
        
        if let reverbDict = (map["reverb"] as? NSDictionary) {
            
            if let state = reverbDict["state"] as? String {
                if let reverbState = EffectsUnitState(rawValue: state) {
                    audioGraphState.reverbState = reverbState
                }
            }
            
            if let space = reverbDict["space"] as? String {
                if let reverbSpace = ReverbSpaces(rawValue: space) {
                    audioGraphState.reverbSpace = reverbSpace
                }
            }
            
            if let amount = reverbDict["amount"] as? NSNumber {
                audioGraphState.reverbAmount = amount.floatValue
            }
            
            // Reverb user presets
            if let userPresets = reverbDict["userPresets"] as? [NSDictionary] {
                
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
                        
                        audioGraphState.reverbUserPresets.append(ReverbPreset(name: presetName, space: ReverbSpaces(rawValue: presetSpace!)!, amount: presetAmount!))
                    }
                })
            }
        }
        
        if let delayDict = (map["delay"] as? NSDictionary) {
            
            if let state = delayDict["state"] as? String {
                if let delayState = EffectsUnitState(rawValue: state) {
                    audioGraphState.delayState = delayState
                }
            }
            
            if let amount = delayDict["amount"] as? NSNumber {
                audioGraphState.delayAmount = amount.floatValue
            }
            
            if let time = delayDict["time"] as? NSNumber {
                audioGraphState.delayTime = time.doubleValue
            }
            
            if let feedback = delayDict["feedback"] as? NSNumber {
                audioGraphState.delayFeedback = feedback.floatValue
            }
            
            if let cutoff = delayDict["lowPassCutoff"] as? NSNumber {
                audioGraphState.delayLowPassCutoff = cutoff.floatValue
            }
            
            // Delay user presets
            if let userPresets = delayDict["userPresets"] as? [NSDictionary] {
                
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
                        
                        audioGraphState.delayUserPresets.append(DelayPreset(name: presetName, amount: presetAmount!, time: presetTime!, feedback: presetFeedback!, cutoff: presetCutoff!, systemDefined: false))
                    }
                })
            }
        }
        
        if let filterDict = (map["filter"] as? NSDictionary) {
            
            if let state = filterDict["state"] as? String {
                if let filterState = EffectsUnitState(rawValue: state) {
                    audioGraphState.filterState = filterState
                }
            }
            
            if let bassMin = (filterDict["bassMin"] as? NSNumber) {
                audioGraphState.filterBassMin = bassMin.floatValue
            }
            
            if let bassMax = (filterDict["bassMax"] as? NSNumber) {
                audioGraphState.filterBassMax = bassMax.floatValue
            }
            
            if let midMin = (filterDict["midMin"] as? NSNumber) {
                audioGraphState.filterMidMin = midMin.floatValue
            }
            
            if let midMax = (filterDict["midMax"] as? NSNumber) {
                audioGraphState.filterMidMax = midMax.floatValue
            }
            
            if let trebleMin = (filterDict["trebleMin"] as? NSNumber) {
                audioGraphState.filterTrebleMin = trebleMin.floatValue
            }
            
            if let trebleMax = (filterDict["trebleMax"] as? NSNumber) {
                audioGraphState.filterTrebleMax = trebleMax.floatValue
            }
            
            // Filter user presets
            if let userPresets = filterDict["userPresets"] as? [NSDictionary] {
                
                userPresets.forEach({
                    
                    var presetName: String?
                    
                    var presetBassMin: Double?
                    var presetBassMax: Double?
                    
                    var presetMidMin: Double?
                    var presetMidMax: Double?
                    
                    var presetTrebleMin: Double?
                    var presetTrebleMax: Double?
                    
                    if let name = $0["name"] as? String {
                        presetName = name
                    }
                    
                    if let bassMin = $0["bassMin"] as? NSNumber {
                        presetBassMin = bassMin.doubleValue
                    }
                    
                    if let bassMax = $0["bassMax"] as? NSNumber {
                        presetBassMax = bassMax.doubleValue
                    }
                    
                    if let midMin = $0["midMin"] as? NSNumber {
                        presetMidMin = midMin.doubleValue
                    }
                    
                    if let midMax = $0["midMax"] as? NSNumber {
                        presetMidMax = midMax.doubleValue
                    }
                    
                    if let trebleMin = $0["trebleMin"] as? NSNumber {
                        presetTrebleMin = trebleMin.doubleValue
                    }
                    
                    if let trebleMax = $0["trebleMax"] as? NSNumber {
                        presetTrebleMax = trebleMax.doubleValue
                    }
                    
                    // Preset must have a name
                    if let presetName = presetName {
                        
                        audioGraphState.filterUserPresets.append(FilterPreset(name: presetName, bassBand: presetBassMin!...presetBassMax!, midBand: presetMidMin!...presetMidMax!, trebleBand: presetTrebleMin!...presetTrebleMax!, systemDefined: false))
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
    
    func toSerializableMap() -> NSDictionary {
        
        var map = [NSString: AnyObject]()
        
        var tracksArr = [String]()
        tracks.forEach({tracksArr.append($0.path)})
        map["tracks"] = NSArray(array: tracksArr)
        
        return map as NSDictionary
    }
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = PlaylistState()
        
        if let tracks = map["tracks"] as? [String] {
            tracks.forEach({state.tracks.append(URL(fileURLWithPath: $0))})
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
    
    var bookmarks: [(name: String, file: URL, position: Double)] = [(name: String, file: URL, position: Double)]()
    
    func toSerializableArray() -> NSArray {
        
        var bookmarksArr = [NSDictionary]()
        bookmarks.forEach({
            
            var map = [NSString: AnyObject]()
            map["name"] = $0.name as AnyObject
            map["file"] = $0.file.path as AnyObject
            map["position"] = $0.position as NSNumber
            
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
                    let position = bookmarkMap.value(forKey: "position") as? NSNumber {
                    
                    state.bookmarks.append((name, URL(fileURLWithPath: file), position.doubleValue))
                }
            }
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
    
    static let defaults: AppState = AppState()
    
    private init() {
        
        self.uiState = UIState()
        self.audioGraphState = AudioGraphState()
        self.playlistState = PlaylistState()
        self.playbackSequenceState = PlaybackSequenceState()
        self.historyState = HistoryState()
        self.favoritesState = FavoritesState()
        self.bookmarksState = BookmarksState()
    }
    
    init(_ uiState: UIState, _ audioGraphState: AudioGraphState, _ playlistState: PlaylistState, _ playbackSequenceState: PlaybackSequenceState, _ historyState: HistoryState, _ favoritesState: FavoritesState, _ bookmarksState: BookmarksState) {
        
        self.uiState = uiState
        self.audioGraphState = audioGraphState
        self.playlistState = playlistState
        self.playbackSequenceState = playbackSequenceState
        self.historyState = historyState
        self.favoritesState = favoritesState
        self.bookmarksState = bookmarksState
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
        
        return state
    }
}
