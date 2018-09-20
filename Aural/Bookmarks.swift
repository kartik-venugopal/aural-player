import Foundation

class Bookmarks: BookmarksProtocol {
    
    private var bookmarks: [Bookmark] = [Bookmark]()
 
    func addBookmark(_ name: String, _ file: URL, _ position: Double) -> Bookmark {
        
        let bookmark = Bookmark(name, file, position)
        bookmarks.append(bookmark)
        return bookmark
    }
    
    func getAllBookmarks() -> [Bookmark] {
        
        // Make a copy and return the copy
        let allBookmarks = bookmarks
        return allBookmarks
    }
}
