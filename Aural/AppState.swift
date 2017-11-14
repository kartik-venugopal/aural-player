import Cocoa

protocol PersistentObject {
    
    func persistentState()
}

protocol PersistentState {

    func serializableMap() -> NSDictionary
    
    static func deserialize(_ map: NSDictionary) -> PersistentState
}

/*
    Encapsulates UI state
 */
class UIState {
    
    var windowLocationX: Float = AppDefaults.windowLocationX
    var windowLocationY: Float = AppDefaults.windowLocationY
    
    var showPlaylist: Bool = AppDefaults.showPlaylist
    var showEffects: Bool = AppDefaults.showEffects
    
    var playlistLocation: PlaylistLocations = AppDefaults.playlistLocation
}

/*
    Encapsulates audio graph state
 */
class AudioGraphState {
    
    var volume: Float = AppDefaults.volume
    var muted: Bool = AppDefaults.muted
    var balance: Float = AppDefaults.balance
    
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
    
    init() {
        
        // Freqs are powers of 2, starting with 2^5=32 ... 2^14=16k
        for i in 5...14 {
            eqBands[Int(pow(2.0, Double(i)))] = AppDefaults.eqBandGain
        }
    }
}

/*
    Encapsulates playlist state
 */
class PlaylistState {
    
    // List of track files
    var tracks: [URL] = [URL]()
}

/*
    Encapsulates playback sequence state
 */
class PlaybackSequenceState {
    
    var repeatMode: RepeatMode = AppDefaults.repeatMode
    var shuffleMode: ShuffleMode = AppDefaults.shuffleMode
}

class HistoryState {
    
    var recentlyAdded: [URL] = [URL]()
    var recentlyPlayed: [URL] = [URL]()
    var favorites: [URL] = [URL]()
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
    func forWritingAsJSON() -> NSDictionary {
        
        var dict = [NSString: AnyObject]()
        
        var uiDict = [NSString: AnyObject]()
        
        uiDict["showPlaylist"] = uiState.showPlaylist as AnyObject
        uiDict["showEffects"] = uiState.showEffects as AnyObject
        
        uiDict["windowLocationX"] = uiState.windowLocationX as NSNumber
        uiDict["windowLocationY"] = uiState.windowLocationY as NSNumber
        
        uiDict["playlistLocation"] = uiState.playlistLocation.rawValue as AnyObject
        
        dict["ui"] = uiDict as AnyObject
        
        var audioGraphDict = [NSString: AnyObject]()
        
        audioGraphDict["volume"] = audioGraphState.volume as NSNumber
        audioGraphDict["muted"] = audioGraphState.muted as AnyObject
        audioGraphDict["balance"] = audioGraphState.balance as NSNumber
        
        var eqDict = [NSString: AnyObject]()
        eqDict["globalGain"] = audioGraphState.eqGlobalGain as NSNumber
        
        var eqBandsDict = [NSString: NSNumber]()
        for (index, gain) in audioGraphState.eqBands {
            eqBandsDict[String(index) as NSString] = gain as NSNumber
        }
        eqDict["bands"] = eqBandsDict as AnyObject
        
        audioGraphDict["eq"] = eqDict as AnyObject
        
        var pitchDict = [NSString: AnyObject]()
        pitchDict["bypass"] = audioGraphState.pitchBypass as AnyObject
        pitchDict["pitch"] = audioGraphState.pitch as NSNumber
        pitchDict["overlap"] = audioGraphState.pitchOverlap as NSNumber
        
        audioGraphDict["pitch"] = pitchDict as AnyObject
        
        var timeDict = [NSString: AnyObject]()
        timeDict["bypass"] = audioGraphState.timeBypass as AnyObject
        timeDict["rate"] = audioGraphState.timeStretchRate as NSNumber
        timeDict["overlap"] = audioGraphState.timeOverlap as NSNumber
        
        audioGraphDict["time"] = timeDict as AnyObject
        
        var reverbDict = [NSString: AnyObject]()
        reverbDict["bypass"] = audioGraphState.reverbBypass as AnyObject
        reverbDict["preset"] = audioGraphState.reverbPreset.rawValue as AnyObject
        reverbDict["amount"] = audioGraphState.reverbAmount as NSNumber
        
        audioGraphDict["reverb"] = reverbDict as AnyObject
        
        var delayDict = [NSString: AnyObject]()
        delayDict["bypass"] = audioGraphState.delayBypass as AnyObject
        delayDict["amount"] = audioGraphState.delayAmount as NSNumber
        delayDict["time"] = audioGraphState.delayTime as NSNumber
        delayDict["feedback"] = audioGraphState.delayFeedback as NSNumber
        delayDict["lowPassCutoff"] = audioGraphState.delayLowPassCutoff as NSNumber
        
        audioGraphDict["delay"] = delayDict as AnyObject
        
        var filterDict = [NSString: AnyObject]()
        filterDict["bypass"] = audioGraphState.filterBypass as AnyObject
        filterDict["bassMin"] = audioGraphState.filterBassMin as NSNumber
        filterDict["bassMax"] = audioGraphState.filterBassMax as NSNumber
        filterDict["midMin"] = audioGraphState.filterMidMin as NSNumber
        filterDict["midMax"] = audioGraphState.filterMidMax as NSNumber
        filterDict["trebleMin"] = audioGraphState.filterTrebleMin as NSNumber
        filterDict["trebleMax"] = audioGraphState.filterTrebleMax as NSNumber
        
        audioGraphDict["filter"] = filterDict as AnyObject
        
        dict["audioGraph"] = audioGraphDict as AnyObject
        
        var playbackSequenceDict = [NSString: AnyObject]()
        
        playbackSequenceDict["repeatMode"] = playbackSequenceState.repeatMode.rawValue as AnyObject
        playbackSequenceDict["shuffleMode"] = playbackSequenceState.shuffleMode.rawValue as AnyObject
        
        dict["playbackSequence"] = playbackSequenceDict as AnyObject
        
        var playlistDict = [NSString: AnyObject]()
        
        var tracksArr = [String]()
        playlistState.tracks.forEach({tracksArr.append($0.path)})
        playlistDict["tracks"] = NSArray(array: tracksArr)
        
        dict["playlist"] = playlistDict as AnyObject
        
        var historyDict = [NSString: AnyObject]()
        
        var recentlyAddedArr = [String]()
        historyState.recentlyAdded.forEach({recentlyAddedArr.append($0.path)})
        historyDict["recentlyAdded"] = NSArray(array: recentlyAddedArr)
        
        var recentlyPlayedArr = [String]()
        historyState.recentlyPlayed.forEach({recentlyPlayedArr.append($0.path)})
        historyDict["recentlyPlayed"] = NSArray(array: recentlyPlayedArr)
        
        var favoritesArr = [String]()
        historyState.favorites.forEach({favoritesArr.append($0.path)})
        historyDict["favorites"] = NSArray(array: favoritesArr)
        
        dict["history"] = historyDict as AnyObject
        
        return dict as NSDictionary
    }
    
    // Produces a AppState object from deserialized JSON
    static func fromJSON(_ jsonObject: NSDictionary) -> AppState {
        
        let state = AppState()
        
        // UI state
        
        if let uiDict = (jsonObject["ui"] as? NSDictionary) {
            
            if let showPlaylist = uiDict["showPlaylist"] as? Bool {
                state.uiState.showPlaylist = showPlaylist
            }
            
            if let showEffects = uiDict["showEffects"] as? Bool {
                state.uiState.showEffects = showEffects
            }
            
            if let locX = uiDict["windowLocationX"] as? NSNumber {
                state.uiState.windowLocationX = locX.floatValue
            }
            
            if let locY = uiDict["windowLocationY"] as? NSNumber {
                state.uiState.windowLocationY = locY.floatValue
            }
            
            if let playlistLocationStr = uiDict["playlistLocation"] as? String {
                if let playlistLocation = PlaylistLocations(rawValue: playlistLocationStr) {
                    state.uiState.playlistLocation = playlistLocation
                }
            }
        }
        
        // Audio graph state
        
        if let audioGraphDict = (jsonObject["audioGraph"] as? NSDictionary) {
            
            let audioGraphState = state.audioGraphState
            
            if let volume = audioGraphDict["volume"] as? NSNumber {
                audioGraphState.volume = volume.floatValue
            }
            
            if let muted = audioGraphDict["muted"] as? Bool {
                audioGraphState.muted = muted
            }
            
            if let balance = audioGraphDict["balance"] as? NSNumber {
                audioGraphState.balance = balance.floatValue
            }
            
            if let eqDict = (audioGraphDict["eq"] as? NSDictionary) {
                
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
            
            if let pitchDict = (audioGraphDict["pitch"] as? NSDictionary) {
                
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
            
            if let timeDict = (audioGraphDict["time"] as? NSDictionary) {
                
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
            
            if let reverbDict = (audioGraphDict["reverb"] as? NSDictionary) {
                
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
            
            if let delayDict = (audioGraphDict["delay"] as? NSDictionary) {
                
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
            
            if let filterDict = (audioGraphDict["filter"] as? NSDictionary) {
                
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
        }
        
        if let playbackSequenceDict = (jsonObject["playbackSequence"] as? NSDictionary) {
            
            if let repeatModeStr = playbackSequenceDict["repeatMode"] as? String {
                if let repeatMode = RepeatMode(rawValue: repeatModeStr) {
                    state.playbackSequenceState.repeatMode = repeatMode
                }
            }
            
            if let shuffleModeStr = playbackSequenceDict["shuffleMode"] as? String {
                if let shuffleMode = ShuffleMode(rawValue: shuffleModeStr) {
                    state.playbackSequenceState.shuffleMode = shuffleMode
                }
            }
        }
        
        if let playlistDict = (jsonObject["playlist"] as? NSDictionary) {
            
            if let tracks = playlistDict["tracks"] as? [String] {
                tracks.forEach({state.playlistState.tracks.append(URL(fileURLWithPath: $0))})
            }
        }
        
        if let historyDict = (jsonObject["history"] as? NSDictionary) {
            
            if let recentlyAdded = historyDict["recentlyAdded"] as? [String] {
                recentlyAdded.forEach({state.historyState.recentlyAdded.append(URL(fileURLWithPath: $0))})
            }
            
            if let recentlyPlayed = historyDict["recentlyPlayed"] as? [String] {
                recentlyPlayed.forEach({state.historyState.recentlyPlayed.append(URL(fileURLWithPath: $0))})
            }
            
            if let favorites = historyDict["favorites"] as? [String] {
                favorites.forEach({state.historyState.favorites.append(URL(fileURLWithPath: $0))})
            }
        }
        
        return state
    }
}
