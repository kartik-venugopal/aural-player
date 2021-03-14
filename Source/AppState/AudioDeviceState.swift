import Foundation

/*
    Encapsulates an audio output device (remembered device)
 */
class AudioDeviceState: PersistentState {
    
    var name: String = ""
    var uid: String = ""
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state: AudioDeviceState = AudioDeviceState()
        
        if let name = (map["name"] as? String) {
            state.name = name
        }
        
        if let uid = (map["uid"] as? String) {
            state.uid = uid
        }
        
        return state
    }
}
