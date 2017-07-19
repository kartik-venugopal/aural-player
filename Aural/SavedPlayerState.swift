/*
Encapsulates all AuralPlayer settings/state. Is persisted to disk upon exit and loaded into the application upon startup.
*/

import Cocoa

class SavedPlayerState {
    
    // Set defaults so that, if the config file cannot be found/loaded, UI can
    // use defaults
    
    var showPlaylist: Bool = PlayerDefaults.showPlaylist
    var showEffects: Bool = PlayerDefaults.showPlaylist
    
    var repeatMode: RepeatMode = PlayerDefaults.repeatMode
    var shuffleMode: ShuffleMode = PlayerDefaults.shuffleMode
    
    var volume: Float = PlayerDefaults.volume
    var muted: Bool = PlayerDefaults.muted
    var balance: Float = PlayerDefaults.balance
    
    var eqGlobalGain: Float = PlayerDefaults.eqGlobalGain
    var eqBands: [Int: Float] = [Int: Float]() // Freq -> Gain
    
    var pitchBypass: Bool = PlayerDefaults.pitchBypass
    var pitch: Float = PlayerDefaults.pitch
    var pitchOverlap: Float = PlayerDefaults.pitchOverlap
    
    var timeBypass: Bool = PlayerDefaults.timeBypass
    var timeStretchRate: Float = PlayerDefaults.timeStretchRate
    
    var reverbBypass: Bool = PlayerDefaults.reverbBypass
    var reverbPreset: ReverbPresets = PlayerDefaults.reverbPreset
    var reverbAmount: Float = PlayerDefaults.reverbAmount
    
    var delayBypass: Bool = PlayerDefaults.delayBypass
    var delayAmount: Float = PlayerDefaults.delayAmount
    var delayTime: Double = PlayerDefaults.delayTime
    var delayFeedback: Float = PlayerDefaults.delayFeedback
    var delayLowPassCutoff: Float = PlayerDefaults.delayLowPassCutoff
    
    var filterBypass: Bool = PlayerDefaults.filterBypass
    var filterLowPassCutoff: Float = PlayerDefaults.filterLowPassCutoff
    var filterHighPassCutoff: Float = PlayerDefaults.filterHighPassCutoff
    
    // List of track file paths
    var playlist: [String] = [String]()
    
    static let defaults: SavedPlayerState = SavedPlayerState()
    
    init() {
        
        // Freqs are powers of 2, starting with 2^5=32 ... 2^14=16k
        for i in 5...14 {
            eqBands[Int(pow(2.0, Double(i)))] = PlayerDefaults.eqBandGain
        }
    }
    
    // Produces an equivalent object suitable for serialization as JSON
    func forWritingAsJSON() -> NSDictionary {
        
        var dict = [NSString: AnyObject]()
        
        dict["showPlaylist"] = showPlaylist
        dict["showEffects"] = showEffects
        
        dict["repeatMode"] = repeatMode.toString
        dict["shuffleMode"] = shuffleMode.toString
        
        dict["volume"] = volume as NSNumber
        dict["muted"] = muted
        dict["balance"] = balance as NSNumber
        
        dict["eqGlobalGain"] = eqGlobalGain as NSNumber
        
        var eqBandsDict = [NSString: NSNumber]()
        for (freq,gain) in eqBands {
            eqBandsDict[String(freq)] = gain as NSNumber
        }
        dict["eqBands"] = eqBandsDict
        
        var pitchDict = [NSString: AnyObject]()
        pitchDict["bypass"] = pitchBypass
        pitchDict["pitch"] = pitch as NSNumber
        pitchDict["overlap"] = pitchOverlap as NSNumber
        dict["pitch"] = pitchDict
        
        var timeDict = [NSString: AnyObject]()
        timeDict["bypass"] = timeBypass
        timeDict["rate"] = timeStretchRate as NSNumber
        dict["time"] = timeDict
        
        var reverbDict = [NSString: AnyObject]()
        reverbDict["bypass"] = reverbBypass
        reverbDict["preset"] = reverbPreset.toString
        reverbDict["amount"] = reverbAmount as NSNumber
        dict["reverb"] = reverbDict
        
        var delayDict = [NSString: AnyObject]()
        delayDict["bypass"] = delayBypass
        delayDict["amount"] = delayAmount as NSNumber
        delayDict["time"] = delayTime as NSNumber
        delayDict["feedback"] = delayFeedback as NSNumber
        delayDict["lowPassCutoff"] = delayLowPassCutoff as NSNumber
        dict["delay"] = delayDict
        
        var filterDict = [NSString: AnyObject]()
        filterDict["bypass"] = filterBypass
        filterDict["highPassCutoff"] = filterHighPassCutoff as NSNumber
        filterDict["lowPassCutoff"] = filterLowPassCutoff as NSNumber
        dict["filter"] = filterDict
        
        dict["playlist"] = NSArray(array: playlist)
        
        return dict
    }
    
    // Produces a SavedPlayerState object from deserialized JSON
    static func fromJSON(jsonObject: NSDictionary) -> SavedPlayerState  {
        
        // TODO: Make this more resilient to missing/invalid fields
        
        let state = SavedPlayerState()
        
        if let showPlaylist = jsonObject["showPlaylist"] as? Bool {
            state.showPlaylist = showPlaylist
        }
        
        if let showEffects = jsonObject["showEffects"] as? Bool {
            state.showEffects = showEffects
        }
        
        if let repeatMode = jsonObject["repeatMode"] as? String {
            state.repeatMode = RepeatMode.fromString(repeatMode)
        }
        
        if let shuffleMode = jsonObject["shuffleMode"] as? String {
            state.shuffleMode = ShuffleMode.fromString(shuffleMode)
        }
        
        state.volume = (jsonObject["volume"] as! NSNumber).floatValue
        state.muted = (jsonObject["muted"] as! Bool)
        state.balance = (jsonObject["balance"] as! NSNumber).floatValue
        
        state.eqGlobalGain = (jsonObject["eqGlobalGain"] as! NSNumber).floatValue
        
        let eqBands: NSDictionary = jsonObject["eqBands"] as! NSDictionary
        for (freq,gain) in eqBands {
            let freqInt = Int(freq as! String)
            state.eqBands[freqInt!] = (gain as! NSNumber).floatValue
        }
        
        if let pitchDict = (jsonObject["pitch"] as? NSDictionary) {
            state.pitchBypass = (pitchDict["bypass"] as! Bool)
            state.pitch = (pitchDict["pitch"] as! NSNumber).floatValue
            state.pitchOverlap = (pitchDict["overlap"] as! NSNumber).floatValue
        }
        
        if let timeDict = (jsonObject["time"] as? NSDictionary) {
            state.timeBypass = (timeDict["bypass"] as! Bool)
            state.timeStretchRate = (timeDict["rate"] as! NSNumber).floatValue
        }
        
        if let reverbDict = (jsonObject["reverb"] as? NSDictionary) {
            state.reverbBypass = (reverbDict["bypass"] as! Bool)
            state.reverbPreset = ReverbPresets.fromString(reverbDict["preset"] as! String)
            state.reverbAmount = (reverbDict["amount"] as! NSNumber).floatValue
        }
        
        if let delayDict = (jsonObject["delay"] as? NSDictionary) {
            state.delayBypass = (delayDict["bypass"] as! Bool)
            state.delayAmount = (delayDict["amount"] as! NSNumber).floatValue
            state.delayTime = (delayDict["time"] as! NSNumber).doubleValue
            state.delayFeedback = (delayDict["feedback"] as! NSNumber).floatValue
            state.delayLowPassCutoff = (delayDict["lowPassCutoff"] as! NSNumber).floatValue
        }
        
        if let filterDict = (jsonObject["filter"] as? NSDictionary) {
            state.filterBypass = (filterDict["bypass"] as! Bool)
            state.filterHighPassCutoff = (filterDict["highPassCutoff"] as! NSNumber).floatValue
            state.filterLowPassCutoff = (filterDict["lowPassCutoff"] as! NSNumber).floatValue
        }
        
        if let playlist = jsonObject["playlist"] as? [String] {
            state.playlist = playlist
        }
        
        return state
    }
}