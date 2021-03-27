/*
 Handles loading/saving of app user preferences
 */
import Foundation
import Cocoa

// Contract for a persistent preferences object
protocol PersistentPreferencesProtocol {
    
    init(_ defaultsDictionary: [String: Any])
    
    func persist(defaults: UserDefaults)
}

class Preferences: PersistentPreferencesProtocol {
    
    private static let singleton: Preferences = Preferences(defaultsDict)
    
    fileprivate static let defaults: UserDefaults = UserDefaults.standard
    fileprivate static let defaultsDict: [String: Any] = defaults.dictionaryRepresentation()
    
    // The (cached) user preferences. Values are held in these variables during app execution, and persisted prior to exiting.
    
    var playbackPreferences: PlaybackPreferences
    var soundPreferences: SoundPreferences
    var playlistPreferences: PlaylistPreferences
    var viewPreferences: ViewPreferences
    var historyPreferences: HistoryPreferences
    var controlsPreferences: ControlsPreferences
    var metadataPreferences: MetadataPreferences
    
    private var allPreferences: [PersistentPreferencesProtocol] = []
    
    internal required init(_ defaultsDictionary: [String: Any]) {
        
        controlsPreferences = ControlsPreferences(defaultsDictionary)
        playbackPreferences = PlaybackPreferences(defaultsDictionary, controlsPreferences)
        soundPreferences = SoundPreferences(defaultsDictionary, controlsPreferences)
        playlistPreferences = PlaylistPreferences(defaultsDictionary)
        
        viewPreferences = ViewPreferences(defaultsDictionary)
        historyPreferences = HistoryPreferences(defaultsDictionary)
        metadataPreferences = MetadataPreferences(defaultsDictionary)
        
        allPreferences = [playbackPreferences, soundPreferences, playlistPreferences, viewPreferences, historyPreferences, controlsPreferences]
    }
    
    func persist(defaults: UserDefaults) {
        allPreferences.forEach({$0.persist(defaults: defaults)})
    }
    
    static var instance: Preferences {
        return singleton
    }
    
    // Saves the preferences to disk (copies the values from the cache to UserDefaults)
    static func persist(_ preferences: Preferences) {
        preferences.persist(defaults: defaults)
    }
}
