/*
 Handles loading/saving of app user preferences
 */
import Foundation
import Cocoa

// Contract for a persistent preferences object
protocol PersistentPreferencesProtocol {
    
    init(_ defaultsDictionary: [String: Any])
    
    func persist(to defaults: UserDefaults)
}

class Preferences {
    
    static let instance: Preferences = Preferences()
    
    private let defaults: UserDefaults = UserDefaults.standard
    
    // The (cached) user preferences.
    
    let playbackPreferences: PlaybackPreferences
    let soundPreferences: SoundPreferences
    let playlistPreferences: PlaylistPreferences
    let viewPreferences: ViewPreferences
    let historyPreferences: HistoryPreferences
    let controlsPreferences: ControlsPreferences
    let metadataPreferences: MetadataPreferences
    
    private let allPreferences: [PersistentPreferencesProtocol]
    
    private init() {
        
        let defaultsDictionary: [String: Any] = defaults.dictionaryRepresentation()
        
        controlsPreferences = ControlsPreferences(defaultsDictionary)
        playbackPreferences = PlaybackPreferences(defaultsDictionary, controlsPreferences.gestures)
        soundPreferences = SoundPreferences(defaultsDictionary, controlsPreferences.gestures)
        playlistPreferences = PlaylistPreferences(defaultsDictionary)
        
        viewPreferences = ViewPreferences(defaultsDictionary)
        historyPreferences = HistoryPreferences(defaultsDictionary)
        metadataPreferences = MetadataPreferences(defaultsDictionary)
        
        allPreferences = [playbackPreferences, soundPreferences, playlistPreferences, viewPreferences,
                          historyPreferences, controlsPreferences, metadataPreferences]
    }
    
    func persist() {
        
        DispatchQueue.global(qos: .utility).async {
            self.allPreferences.forEach {$0.persist(to: self.defaults)}
        }
    }
}
