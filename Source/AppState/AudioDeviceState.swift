import Foundation

/*
    Encapsulates an audio output device (remembered device)
 */
class AudioDeviceState: PersistentStateProtocol {
    
    let name: String
    let uid: String
    
    required init?(_ map: NSDictionary) {
        
        guard let name = map.stringValue(forKey: "name"),
              let uid = map.stringValue(forKey: "uid") else {return nil}
        
        self.name = name
        self.uid = uid
    }
}
