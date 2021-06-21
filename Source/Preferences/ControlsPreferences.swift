import Cocoa

class ControlsPreferences: PersistentPreferencesProtocol {
    
    var mediaKeys: MediaKeysControlsPreferences
    var gestures: GesturesControlsPreferences
    var remoteControl: RemoteControlPreferences
    
    internal required init(_ dict: [String: Any]) {
        
        mediaKeys = MediaKeysControlsPreferences(dict)
        gestures = GesturesControlsPreferences(dict)
        remoteControl = RemoteControlPreferences(dict)
    }
    
    func persist(to defaults: UserDefaults) {
        
        mediaKeys.persist(to: defaults)
        gestures.persist(to: defaults)
        remoteControl.persist(to: defaults)
    }
}
