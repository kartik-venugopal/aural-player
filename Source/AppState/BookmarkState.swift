import Foundation

class BookmarkState: PersistentStateProtocol {
    
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
        
        guard let name = map.stringValue(forKey: "name"),
              let file = map.urlValue(forKey: "file"),
              let startPosition = map.doubleValue(forKey: "startPosition") else {return nil}
            
        self.name = name
        self.file = file
        self.startPosition = startPosition
        self.endPosition = map.doubleValue(forKey: "endPosition")
    }
}

extension BookmarksDelegate {
    
    var persistentState: [BookmarkState] {
        bookmarks.allBookmarks.map {BookmarkState($0.name, $0.file, $0.startPosition, $0.endPosition)}
    }
}
