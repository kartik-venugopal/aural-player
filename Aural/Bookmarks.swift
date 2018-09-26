import Foundation

class Bookmarks: BookmarksProtocol {

    private var bookmarks: StringKeyedCollection<Bookmark> = StringKeyedCollection<Bookmark>()
    
    func addBookmark(_ name: String, _ file: URL, _ position: Double) -> Bookmark {
        
        let bookmark = Bookmark(name, file, position)
        bookmarks.addItem(bookmark)
        return bookmark
    }
    
    func getAllBookmarks() -> [Bookmark] {
        return bookmarks.getAllItems()
    }
    
    func bookmarkWithNameExists(_ name: String) -> Bool {
        return bookmarks.itemWithKeyExists(name)
    }
    
    func getBookmarkAtIndex(_ index: Int) -> Bookmark {
        return bookmarks.itemAtIndex(index)
    }
    
    func countBookmarks() -> Int {
        return bookmarks.countItems()
    }
    
    func getBookmarkWithName(_ name: String) -> Bookmark? {
        return bookmarks.itemWithKey(name)
    }
    
    func deleteAllBookmarks() {
        bookmarks.removeAllItems()
    }
    
    func deleteBookmarkAtIndex(_ index: Int) {
        bookmarks.removeItemAtIndex(index)
    }
    
    func deleteBookmarkWithName(_ name: String) {
        bookmarks.removeItemWithKey(name)
    }
}
