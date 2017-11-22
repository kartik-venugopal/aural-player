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
    
    // Constructs an instance of this state object from the given map
    static func deserialize(_ map: NSDictionary) -> PersistentState
}

/*
    Encapsulates UI state
 */
class UIState: PersistentState {
    
    var windowLocationX: Float = AppDefaults.windowLocationX
    var windowLocationY: Float = AppDefaults.windowLocationY
    
    var showPlaylist: Bool = AppDefaults.showPlaylist
    var showEffects: Bool = AppDefaults.showEffects
    
    var playlistLocation: PlaylistLocations = AppDefaults.playlistLocation
    
    func toSerializableMap() -> NSDictionary {
        
        var map = [NSString: AnyObject]()
        
        map["showPlaylist"] = showPlaylist as AnyObject
        map["showEffects"] = showEffects as AnyObject
        
        map["windowLocationX"] = windowLocationX as NSNumber
        map["windowLocationY"] = windowLocationY as NSNumber
        
        map["playlistLocation"] = playlistLocation.rawValue as AnyObject
        
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
        
        if let locX = map["windowLocationX"] as? NSNumber {
            uiState.windowLocationX = locX.floatValue
        }
        
        if let locY = map["windowLocationY"] as? NSNumber {
            uiState.windowLocationY = locY.floatValue
        }
        
        if let playlistLocationStr = map["playlistLocation"] as? String {
            if let playlistLocation = PlaylistLocations(rawValue: playlistLocationStr) {
                uiState.playlistLocation = playlistLocation
            }
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
    
    var eqBypass: Bool = AppDefaults.eqBypass
    var eqGlobalGain: Float = AppDefaults.eqGlobalGain
    var eqBands: [Int: Float] = [Int: Float]() // Index -> Gain
    
    var pitchBypass: Bool = AppDefaults.pitchBypass
    var pitch: Float = AppDefaults.pitch
    var pitchOverlap: Float = AppDefaults.pitchOverlap
    
    var timeBypass: Bool = AppDefaults.timeBypass
    var timeStretchRate: Float = AppDefaults.timeStretchRate
    var timeOverlap: Float = AppDefaults.timeOverlap
    
    var reverbBypass: Bool = AppDefaults.reverbBypass
    var reverbPreset: ReverbPresets = AppDefaults.reverbPreset
    var reverbAmount: Float = AppDefaults.reverbAmount
    
    var delayBypass: Bool = AppDefaults.delayBypass
    var delayAmount: Float = AppDefaults.delayAmount
    var delayTime: Double = AppDefaults.delayTime
    var delayFeedback: Float = AppDefaults.delayFeedback
    var delayLowPassCutoff: Float = AppDefaults.delayLowPassCutoff
    
    var filterBypass: Bool = AppDefaults.filterBypass
    var filterBassMin: Float = AppDefaults.filterBassMin
    var filterBassMax: Float = AppDefaults.filterBassMax
    var filterMidMin: Float = AppDefaults.filterMidMin
    var filterMidMax: Float = AppDefaults.filterMidMax
    var filterTrebleMin: Float = AppDefaults.filterTrebleMin
    var filterTrebleMax: Float = AppDefaults.filterTrebleMax
    
    func toSerializableMap() -> NSDictionary {
        
        var map = [NSString: AnyObject]()
        
        map["volume"] = volume as NSNumber
        map["muted"] = muted as AnyObject
        map["balance"] = balance as NSNumber
        
        var eqDict = [NSString: AnyObject]()
        eqDict["bypass"] = eqBypass as AnyObject
        eqDict["globalGain"] = eqGlobalGain as NSNumber
        
        var eqBandsDict = [NSString: NSNumber]()
        for (index, gain) in eqBands {
            eqBandsDict[String(index) as NSString] = gain as NSNumber
        }
        eqDict["bands"] = eqBandsDict as AnyObject
        
        map["eq"] = eqDict as AnyObject
        
        var pitchDict = [NSString: AnyObject]()
        pitchDict["bypass"] = pitchBypass as AnyObject
        pitchDict["pitch"] = pitch as NSNumber
        pitchDict["overlap"] = pitchOverlap as NSNumber
        
        map["pitch"] = pitchDict as AnyObject
        
        var timeDict = [NSString: AnyObject]()
        timeDict["bypass"] = timeBypass as AnyObject
        timeDict["rate"] = timeStretchRate as NSNumber
        timeDict["overlap"] = timeOverlap as NSNumber
        
        map["time"] = timeDict as AnyObject
        
        var reverbDict = [NSString: AnyObject]()
        reverbDict["bypass"] = reverbBypass as AnyObject
        reverbDict["preset"] = reverbPreset.rawValue as AnyObject
        reverbDict["amount"] = reverbAmount as NSNumber
        
        map["reverb"] = reverbDict as AnyObject
        
        var delayDict = [NSString: AnyObject]()
        delayDict["bypass"] = delayBypass as AnyObject
        delayDict["amount"] = delayAmount as NSNumber
        delayDict["time"] = delayTime as NSNumber
        delayDict["feedback"] = delayFeedback as NSNumber
        delayDict["lowPassCutoff"] = delayLowPassCutoff as NSNumber
        
        map["delay"] = delayDict as AnyObject
        
        var filterDict = [NSString: AnyObject]()
        filterDict["bypass"] = filterBypass as AnyObject
        filterDict["bassMin"] = filterBassMin as NSNumber
        filterDict["bassMax"] = filterBassMax as NSNumber
        filterDict["midMin"] = filterMidMin as NSNumber
        filterDict["midMax"] = filterMidMax as NSNumber
        filterDict["trebleMin"] = filterTrebleMin as NSNumber
        filterDict["trebleMax"] = filterTrebleMax as NSNumber
        
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
        
        if let eqDict = (map["eq"] as? NSDictionary) {
            
            if let bypass = eqDict["bypass"] as? Bool {
                audioGraphState.eqBypass = bypass
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
        }
        
        if let pitchDict = (map["pitch"] as? NSDictionary) {
            
            if let bypass = pitchDict["bypass"] as? Bool {
                audioGraphState.pitchBypass = bypass
            }
            
            if let pitch = pitchDict["pitch"] as? NSNumber {
                audioGraphState.pitch = pitch.floatValue
            }
            
            if let overlap = pitchDict["overlap"] as? NSNumber {
                audioGraphState.pitchOverlap = overlap.floatValue
            }
        }
        
        if let timeDict = (map["time"] as? NSDictionary) {
            
            if let bypass = timeDict["bypass"] as? Bool {
                audioGraphState.timeBypass = bypass
            }
            
            if let rate = timeDict["rate"] as? NSNumber {
                audioGraphState.timeStretchRate = rate.floatValue
            }
            
            if let timeOverlap = timeDict["overlap"] as? NSNumber {
                audioGraphState.timeOverlap = timeOverlap.floatValue
            }
        }
        
        if let reverbDict = (map["reverb"] as? NSDictionary) {
            
            if let bypass = reverbDict["bypass"] as? Bool {
                audioGraphState.reverbBypass = bypass
            }
            
            if let preset = reverbDict["preset"] as? String {
                if let reverbPreset = ReverbPresets(rawValue: preset) {
                    audioGraphState.reverbPreset = reverbPreset
                }
            }
            
            if let amount = reverbDict["amount"] as? NSNumber {
                audioGraphState.reverbAmount = amount.floatValue
            }
        }
        
        if let delayDict = (map["delay"] as? NSDictionary) {
            
            if let bypass = delayDict["bypass"] as? Bool {
                audioGraphState.delayBypass = bypass
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
        }
        
        if let filterDict = (map["filter"] as? NSDictionary) {
            
            if let bypass = filterDict["bypass"] as? Bool {
                audioGraphState.filterBypass = bypass
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
    var favorites: [(file: URL, time: Date)] = [(file: URL, time: Date)]()
    
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
        
        var favoritesArr = [NSDictionary]()
        favorites.forEach({
            favoritesArr.append(self.itemToMap($0))
        })
        map["favorites"] = NSArray(array: favoritesArr)
        
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
        
        if let favorites = map["favorites"] as? [NSDictionary] {
            
            favorites.forEach({
                
                if let file = $0.value(forKey: "path") as? String,
                    let timestamp = $0.value(forKey: "timestamp") as? String {
                    
                    state.recentlyPlayed.append((URL(fileURLWithPath: file), Date.fromString(timestamp)))
                }
            })
        }
        
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
    
    static let defaults: AppState = AppState()
    
    private init() {
        
        self.uiState = UIState()
        self.audioGraphState = AudioGraphState()
        self.playlistState = PlaylistState()
        self.playbackSequenceState = PlaybackSequenceState()
        self.historyState = HistoryState()
    }
    
    init(_ uiState: UIState, _ audioGraphState: AudioGraphState, _ playlistState: PlaylistState, _ playbackSequenceState: PlaybackSequenceState, _ historyState: HistoryState) {
        
        self.uiState = uiState
        self.audioGraphState = audioGraphState
        self.playlistState = playlistState
        self.playbackSequenceState = playbackSequenceState
        self.historyState = historyState
    }
    
    // Produces an equivalent object suitable for serialization as JSON
    func toSerializableMap() -> NSDictionary {
        
        var dict = [NSString: AnyObject]()
        
        dict["ui"] = uiState.toSerializableMap() as AnyObject
        dict["audioGraph"] = audioGraphState.toSerializableMap() as AnyObject
        dict["playbackSequence"] = playbackSequenceState.toSerializableMap() as AnyObject
        dict["playlist"] = playlistState.toSerializableMap() as AnyObject
        dict["history"] = historyState.toSerializableMap() as AnyObject
        
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
        
        return state
    }
}
