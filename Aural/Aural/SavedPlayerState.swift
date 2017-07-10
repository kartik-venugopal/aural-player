/*
    Encapsulates all AuralPlayer settings/state. Is persisted to disk upon exit and loaded into the application upon startup.
*/

import Cocoa

class SavedPlayerState {
    
    // Set defaults so that, if the config file cannot be found/loaded, UI can
    // use defaults
    
    // Range: -20 to 20
    var eqGlobalGain: Float = 0
    
    // Freq -> Gain
    // Gain range: -20 to 20
    var eqBands: [Int: Float] = [Int: Float]()
    
    // Range: -2400 to 2400
    var pitch: Float = 0
    
    // Range: 3 to 32
    var pitchOverlap: Float = 3
    
    var reverb: ReverbPresets = ReverbPresets.None
    
    // Range: 0 to 100
    var reverbAmount: Float = 0
    
    // Range: 0 to 1
    var volume: Float = 0.5
    
    var muted: Bool = false
    
    // (Pan) Range: -1 (L) to 1 (R)
    var balance: Float = 0
    
    var repeatMode: RepeatMode = .OFF
    
    var shuffleMode: ShuffleMode = .OFF
    
    // List of track file paths
    var playlist: [String] = [String]()
    
    static let defaults: SavedPlayerState = SavedPlayerState()
    
    init() {
        
        // Freqs are powers of 2, starting with 2^5=32 ... 2^14=16k
        for i in 5...14 {
            eqBands[Int(pow(2.0, Double(i)))] = 0
        }
    }
    
    // Produces an equivalent object suitable for serialization as JSON
    func forWritingAsJSON() -> NSDictionary {
        
        var dict = [NSString: AnyObject]()
        
        dict["eqGlobalGain"] = eqGlobalGain as NSNumber
        
        var eqBandsDict = [NSString: NSNumber]()
        for (freq,gain) in eqBands {
            eqBandsDict[String(freq)] = gain as NSNumber
        }
        dict["eqBands"] = eqBandsDict
        
        dict["pitch"] = pitch as NSNumber
        dict["pitchOverlap"] = pitchOverlap as NSNumber
        
        dict["reverbPreset"] = reverb.toString
        dict["reverbAmount"] = reverbAmount as NSNumber
        
        dict["volume"] = volume as NSNumber
        dict["muted"] = String(muted)
        dict["balance"] = balance as NSNumber
        
        dict["repeatMode"] = repeatMode.toString
        dict["shuffleMode"] = shuffleMode.toString
        
        dict["playlist"] = NSArray(array: playlist)
        
        return dict
    }
    
    // Produces a SavedPlayerState object from deserialized JSON
    static func fromJSON(jsonObject: NSDictionary) -> SavedPlayerState  {
        
        let state = SavedPlayerState()
        
        state.eqGlobalGain = (jsonObject["eqGlobalGain"] as! NSNumber).floatValue
        
        let eqBands: NSDictionary = jsonObject["eqBands"] as! NSDictionary
        for (freq,gain) in eqBands {
            let freqInt = Int(freq as! String)
            state.eqBands[freqInt!] = (gain as! NSNumber).floatValue
        }
        
        state.volume = (jsonObject["volume"] as! NSNumber).floatValue
        state.muted = (jsonObject["muted"] as! NSString).boolValue
        state.balance = (jsonObject["balance"] as! NSNumber).floatValue
        
        state.pitch = (jsonObject["pitch"] as! NSNumber).floatValue
        state.pitchOverlap = (jsonObject["pitchOverlap"] as! NSNumber).floatValue
        
        state.reverb = ReverbPresets.fromString(jsonObject["reverbPreset"] as! String)
        state.reverbAmount = (jsonObject["reverbAmount"] as! NSNumber).floatValue
        
        state.repeatMode = RepeatMode.fromString(jsonObject["repeatMode"] as! String)
        state.shuffleMode = ShuffleMode.fromString(jsonObject["shuffleMode"] as! String)
        
        state.playlist = jsonObject["playlist"] as! [String]
        
        return state
    }
}