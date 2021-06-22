import Foundation

class BookmarkPersistentState: PersistentStateProtocol {
    
    let name: String
    let file: URL
    let startPosition: Double
    let endPosition: Double?
    
    init(_ name: String, _ file: URL, _ startPosition: Double, _ endPosition: Double?) {
        
        self.name = name
        self.file = file
        self.startPosition = startPosition
        self.endPosition = endPosition
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let name = map["name", String.self],
              let file = map.urlValue(forKey: "file"),
              let startPosition = map["startPosition", Double.self] else {return nil}
            
        self.name = name
        self.file = file
        self.startPosition = startPosition
        self.endPosition = map["endPosition", Double.self]
    }
}
