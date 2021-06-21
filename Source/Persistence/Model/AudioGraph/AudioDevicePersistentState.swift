import Foundation

/*
    Encapsulates an audio output device (remembered device)
 */
class AudioDevicePersistentState: PersistentStateProtocol {
    
    let name: String
    let uid: String
    
    init(name: String, uid: String) {
        
        self.name = name
        self.uid = uid
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let name = map["name", String.self],
              let uid = map["uid", String.self] else {return nil}
        
        self.name = name
        self.uid = uid
    }
}
