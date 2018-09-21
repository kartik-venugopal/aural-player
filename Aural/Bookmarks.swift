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
    
    func bookmarkWithNameExists(_ name: String) -> Bool {
        
        var found: Bool = false
        
        bookmarks.forEach({
            if $0.name == name {
                found = true
                return
            }
        })
        
        return found
    }
    
    func getBookmarkAtIndex(_ index: Int) -> Bookmark? {
        return index >= bookmarks.count ? nil : bookmarks[index]
    }
    
    func countBookmarks() -> Int {
        return bookmarks.count
    }
    
    func getBookmarkWithName(_ name: String) -> Bookmark? {
        
        var result: Bookmark? = nil
        
        bookmarks.forEach({
            
            if $0.name == name {
                result = $0
                return
            }
        })
        
        return result
    }
    
    func deleteAllBookmarks() {
        bookmarks.removeAll()
    }
    
    func deleteBookmark(_ name: String) {
        
        if let index = bookmarks.index(where: {$0.name == name}) {
            bookmarks.remove(at: index)
        }
    }
}
