import Cocoa

/*
    Encapsulates UI state
 */
class UIState {
    
    var windowLocationX: Float = AppDefaults.windowLocationX
    var windowLocationY: Float = AppDefaults.windowLocationY
    
    var showPlaylist: Bool = AppDefaults.showPlaylist
    var showEffects: Bool = AppDefaults.showEffects
}

/*
    Encapsulates player state
 */
class PlayerState {
    
    var volume: Float = AppDefaults.volume
    var muted: Bool = AppDefaults.muted
    var balance: Float = AppDefaults.balance
    
    var eqGlobalGain: Float = AppDefaults.eqGlobalGain
    var eqBands: [Int: Float] = [Int: Float]() // Freq -> Gain
    
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
    
    var repeatMode: RepeatMode = AppDefaults.repeatMode
    var shuffleMode: ShuffleMode = AppDefaults.shuffleMode
    
    // List of track file paths
    var tracks: [String] = [String]()
}

/*
    Encapsulates all application state. It is persisted to disk upon exit and loaded into the application upon startup.
 */
class AppState {
    
    var uiState: UIState
    var playerState: PlayerState
    var playlistState: PlaylistState
    
    static let defaults: AppState = AppState()
    
    init() {
        self.uiState = UIState()
        self.playerState = PlayerState()
        self.playlistState = PlaylistState()
    }
    
    init(_ uiState: UIState, _ playerState: PlayerState, _ playlistState: PlaylistState) {
        self.uiState = uiState
        self.playerState = playerState
        self.playlistState = playlistState
    }
    
    // Produces an equivalent object suitable for serialization as JSON
    func forWritingAsJSON() -> NSDictionary {
        
        var dict = [NSString: AnyObject]()
        
        var uiDict = [NSString: AnyObject]()
        
        uiDict["showPlaylist"] = uiState.showPlaylist as AnyObject
        uiDict["showEffects"] = uiState.showEffects as AnyObject
        
        uiDict["windowLocationX"] = uiState.windowLocationX as NSNumber
        uiDict["windowLocationY"] = uiState.windowLocationY as NSNumber
        
        dict["ui"] = uiDict as AnyObject
        
        var playerDict = [NSString: AnyObject]()
        
        playerDict["volume"] = playerState.volume as NSNumber
        playerDict["muted"] = playerState.muted as AnyObject
        playerDict["balance"] = playerState.balance as NSNumber
        
        var eqDict = [NSString: AnyObject]()
        eqDict["globalGain"] = playerState.eqGlobalGain as NSNumber
        
        var eqBandsDict = [NSString: NSNumber]()
        for (freq,gain) in playerState.eqBands {
            eqBandsDict[String(freq) as NSString] = gain as NSNumber
        }
        eqDict["bands"] = eqBandsDict as AnyObject
        
        playerDict["eq"] = eqDict as AnyObject
        
        var pitchDict = [NSString: AnyObject]()
        pitchDict["bypass"] = playerState.pitchBypass as AnyObject
        pitchDict["pitch"] = playerState.pitch as NSNumber
        pitchDict["overlap"] = playerState.pitchOverlap as NSNumber
        
        playerDict["pitch"] = pitchDict as AnyObject
        
        var timeDict = [NSString: AnyObject]()
        timeDict["bypass"] = playerState.timeBypass as AnyObject
        timeDict["rate"] = playerState.timeStretchRate as NSNumber
        timeDict["overlap"] = playerState.timeOverlap as NSNumber
        
        playerDict["time"] = timeDict as AnyObject
        
        var reverbDict = [NSString: AnyObject]()
        reverbDict["bypass"] = playerState.reverbBypass as AnyObject
        reverbDict["preset"] = playerState.reverbPreset.rawValue as AnyObject
        reverbDict["amount"] = playerState.reverbAmount as NSNumber
        
        playerDict["reverb"] = reverbDict as AnyObject
        
        var delayDict = [NSString: AnyObject]()
        delayDict["bypass"] = playerState.delayBypass as AnyObject
        delayDict["amount"] = playerState.delayAmount as NSNumber
        delayDict["time"] = playerState.delayTime as NSNumber
        delayDict["feedback"] = playerState.delayFeedback as NSNumber
        delayDict["lowPassCutoff"] = playerState.delayLowPassCutoff as NSNumber
        
        playerDict["delay"] = delayDict as AnyObject
        
        var filterDict = [NSString: AnyObject]()
        filterDict["bypass"] = playerState.filterBypass as AnyObject
        filterDict["bassMin"] = playerState.filterBassMin as NSNumber
        filterDict["bassMax"] = playerState.filterBassMax as NSNumber
        filterDict["midMin"] = playerState.filterMidMin as NSNumber
        filterDict["midMax"] = playerState.filterMidMax as NSNumber
        filterDict["trebleMin"] = playerState.filterTrebleMin as NSNumber
        filterDict["trebleMax"] = playerState.filterTrebleMax as NSNumber
        
        playerDict["filter"] = filterDict as AnyObject
        
        dict["player"] = playerDict as AnyObject
        
        var playlistDict = [NSString: AnyObject]()
        
        playlistDict["repeatMode"] = playlistState.repeatMode.rawValue as AnyObject
        playlistDict["shuffleMode"] = playlistState.shuffleMode.rawValue as AnyObject
        playlistDict["tracks"] = NSArray(array: playlistState.tracks)
        
        dict["playlist"] = playlistDict as AnyObject
        
        return dict as NSDictionary
    }
    
    // Produces a AppState object from deserialized JSON
    static func fromJSON(_ jsonObject: NSDictionary) -> AppState  {
        
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
        }
        
        // Player state
        
        if let playerDict = (jsonObject["player"] as? NSDictionary) {
        
            let playerState = state.playerState
            
            if let volume = playerDict["volume"] as? NSNumber {
                playerState.volume = volume.floatValue
            }
            
            if let muted = playerDict["muted"] as? Bool {
                playerState.muted = muted
            }
            
            if let balance = playerDict["balance"] as? NSNumber {
                playerState.balance = balance.floatValue
            }
            
            if let eqDict = (playerDict["eq"] as? NSDictionary) {
            
                if let globalGain = eqDict["globalGain"] as? NSNumber {
                    playerState.eqGlobalGain = globalGain.floatValue
                }
                
                if let eqBands: NSDictionary = eqDict["bands"] as? NSDictionary {
                    
                    for (freq, gain) in eqBands {
                        
                        if let freqStr = freq as? String {
                            
                            if let freqInt = Int(freqStr) {
                                
                                if let gainNum = gain as? NSNumber {
                                    playerState.eqBands[freqInt] = gainNum.floatValue
                                }
                            }
                        }
                    }
                }
            }
            
            if let pitchDict = (playerDict["pitch"] as? NSDictionary) {
                
                if let bypass = pitchDict["bypass"] as? Bool {
                    playerState.pitchBypass = bypass
                }
                
                if let pitch = pitchDict["pitch"] as? NSNumber {
                    playerState.pitch = pitch.floatValue
                }
                
                if let overlap = pitchDict["overlap"] as? NSNumber {
                    playerState.pitchOverlap = overlap.floatValue
                }
            }
            
            if let timeDict = (playerDict["time"] as? NSDictionary) {
                
                if let bypass = timeDict["bypass"] as? Bool {
                    playerState.timeBypass = bypass
                }
                
                if let rate = timeDict["rate"] as? NSNumber {
                    playerState.timeStretchRate = rate.floatValue
                }
                
                if let timeOverlap = timeDict["overlap"] as? NSNumber {
                    playerState.timeOverlap = timeOverlap.floatValue
                }
            }
            
            if let reverbDict = (playerDict["reverb"] as? NSDictionary) {
                
                if let bypass = reverbDict["bypass"] as? Bool {
                    playerState.reverbBypass = bypass
                }
                
                if let preset = reverbDict["preset"] as? String {
                    if let reverbPreset = ReverbPresets(rawValue: preset) {
                        playerState.reverbPreset = reverbPreset
                    }
                }
                
                if let amount = reverbDict["amount"] as? NSNumber {
                    playerState.reverbAmount = amount.floatValue
                }
            }
            
            if let delayDict = (playerDict["delay"] as? NSDictionary) {
                
                if let bypass = delayDict["bypass"] as? Bool {
                    playerState.delayBypass = bypass
                }
                
                if let amount = delayDict["amount"] as? NSNumber {
                    playerState.delayAmount = amount.floatValue
                }
                
                if let time = delayDict["time"] as? NSNumber {
                    playerState.delayTime = time.doubleValue
                }
                
                if let feedback = delayDict["feedback"] as? NSNumber {
                    playerState.delayFeedback = feedback.floatValue
                }
                
                if let cutoff = delayDict["lowPassCutoff"] as? NSNumber {
                    playerState.delayLowPassCutoff = cutoff.floatValue
                }
            }
            
            if let filterDict = (playerDict["filter"] as? NSDictionary) {
                
                if let bypass = filterDict["bypass"] as? Bool {
                    playerState.filterBypass = bypass
                }
                
                if let bassMin = (filterDict["bassMin"] as? NSNumber) {
                    playerState.filterBassMin = bassMin.floatValue
                }
                
                if let bassMax = (filterDict["bassMax"] as? NSNumber) {
                    playerState.filterBassMax = bassMax.floatValue
                }
                
                if let midMin = (filterDict["midMin"] as? NSNumber) {
                    playerState.filterMidMin = midMin.floatValue
                }
                
                if let midMax = (filterDict["midMax"] as? NSNumber) {
                    playerState.filterMidMax = midMax.floatValue
                }
                
                if let trebleMin = (filterDict["trebleMin"] as? NSNumber) {
                    playerState.filterTrebleMin = trebleMin.floatValue
                }
                
                if let trebleMax = (filterDict["trebleMax"] as? NSNumber) {
                    playerState.filterTrebleMax = trebleMax.floatValue
                }
            }
        }
        
        if let playlistDict = (jsonObject["playlist"] as? NSDictionary) {
        
            if let repeatModeStr = playlistDict["repeatMode"] as? String {
                if let repeatMode = RepeatMode(rawValue: repeatModeStr) {
                    state.playlistState.repeatMode = repeatMode
                }
            }
            
            if let shuffleModeStr = playlistDict["shuffleMode"] as? String {
                if let shuffleMode = ShuffleMode(rawValue: shuffleModeStr) {
                    state.playlistState.shuffleMode = shuffleMode
                }
            }
            
            if let tracks = playlistDict["tracks"] as? [String] {
                state.playlistState.tracks = tracks
            }
        }
        
        return state
    }
}
