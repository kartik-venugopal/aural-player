import Foundation

class PlaybackProfilePersistentState: PersistentStateProtocol {
    
    let file: URL
    var lastPosition: Double
    
    init(file: URL, lastPosition: Double) {
        
        self.file = file
        self.lastPosition = lastPosition
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let file = map.urlValue(forKey: "file"),
              let lastPosition = map["lastPosition", Double.self] else {return nil}
        
        self.file = file
        self.lastPosition = lastPosition
    }
}
