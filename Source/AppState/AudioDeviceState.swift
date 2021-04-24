import Foundation

/*
    Encapsulates an audio output device (remembered device)
 */
class AudioDeviceState: PersistentStateProtocol {
    
    var name: String = ""
    var uid: String = ""
    
    required init?(_ map: NSDictionary) -> AudioDeviceState {
        
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
