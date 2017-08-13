/*
    Handles loading/saving of app user preferences
 */
import Foundation
import Cocoa

class Preferences {
    
    private static let singleton: Preferences = Preferences()
    
    private static let defaults: UserDefaults = UserDefaults.standard
    private static let defaultsDict: [String: Any] = defaults.dictionaryRepresentation()
    
    // Defaults values to use if saved preferences are unavailable
    private static let defaultSeekLength: Int = 5
    private static let defaultVolumeDelta: Float = 0.05
    private static let defaultPanDelta: Float = 0.1
    
    // The (cached) user preferences. Values are held in these variables during app execution, and persisted upon exiting.
    var seekLength: Int
    var volumeDelta: Float
    var panDelta: Float
    
    private init() {
        seekLength = Preferences.defaultsDict["seekLength"] as? Int ?? Preferences.defaultSeekLength
        volumeDelta = Preferences.defaultsDict["volumeDelta"] as? Float ?? Preferences.defaultVolumeDelta
        panDelta = Preferences.defaultsDict["panDelta"] as? Float ?? Preferences.defaultPanDelta
    }
    
    static func instance() -> Preferences {
        return singleton
    }
    
    // Saves the preferences to disk (copies the values from the cache to UserDefaults)
    static func persist() {
        defaults.set(singleton.seekLength, forKey: "seekLength")
        defaults.set(singleton.volumeDelta, forKey: "volumeDelta")
        defaults.set(singleton.panDelta, forKey: "panDelta")
    }
}
