import Foundation

class Bookmarks: BookmarksProtocol {
    
    private var bookmarks: StringKeyedCollection<Bookmark> = StringKeyedCollection<Bookmark>()
    
    func addBookmark(_ name: String, _ file: URL, _ startPosition: Double, _ endPosition: Double? = nil) -> Bookmark {
        
        let bookmark = Bookmark(name, file, startPosition, endPosition)
        bookmarks.addItem(bookmark)
        return bookmark
    }
    
    var allBookmarks: [Bookmark] {
        return bookmarks.allItems
    }
    
    func bookmarkWithNameExists(_ name: String) -> Bool {
        return bookmarks.itemWithKeyExists(name)
    }
    
    func getBookmarkAtIndex(_ index: Int) -> Bookmark {
        return bookmarks.itemAtIndex(index)
    }
    
    var count: Int {
        return bookmarks.count
    }
    
    func getBookmarkWithName(_ name: String) -> Bookmark? {
        return bookmarks.itemWithKey(name)
    }
    
    func renameBookmarkAtIndex(_ index: Int, _ newName: String) {

        let item = bookmarks.itemAtIndex(index)
        bookmarks.reMapForKey(item.name, newName)
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
