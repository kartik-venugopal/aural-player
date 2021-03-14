import Foundation

class BookmarkState {
    
    var name: String = ""
    var file: URL
    var startPosition: Double = 0
    var endPosition: Double?
    
    init(_ name: String, _ file: URL, _ startPosition: Double, _ endPosition: Double?) {
        self.name = name
        self.file = file
        self.startPosition = startPosition
        self.endPosition = endPosition
    }
    
    static func deserialize(_ bookmarkMap: NSDictionary) -> BookmarkState? {
        
        if let name = bookmarkMap["name"] as? String, let file = bookmarkMap["file"] as? String {
            
            let startPosition: Double = mapNumeric(bookmarkMap, "startPosition", AppDefaults.lastTrackPosition)
            let endPosition: Double? = mapNumeric(bookmarkMap, "endPosition")
            return BookmarkState(name, URL(fileURLWithPath: file), startPosition, endPosition)
        }
        
        return nil
    }
}

extension BookmarksDelegate {
    
    var persistentState: [BookmarkState] {
        
        var arr = [BookmarkState]()
        
        bookmarks.allBookmarks.forEach({
            arr.append(BookmarkState($0.name, $0.file, $0.startPosition, $0.endPosition))
        })
        
        return arr
    }
}
