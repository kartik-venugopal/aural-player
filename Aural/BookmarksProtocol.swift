import Foundation

protocol BookmarksProtocol {
    
    func addBookmark(_ name: String, _ file: URL, _ startPosition: Double) -> Bookmark
    
    func addBookmark(_ name: String, _ file: URL, _ startPosition: Double, _ endPosition: Double) -> Bookmark
    
    var allBookmarks: [Bookmark] {get}
    
    var count: Int {get}
    
    func getBookmarkAtIndex(_ index: Int) -> Bookmark
    
    func deleteBookmarkAtIndex(_ index: Int)
    
    func deleteBookmarkWithName(_ name: String)
    
    func bookmarkWithNameExists(_ name: String) -> Bool
    
    func getBookmarkWithName(_ name: String) -> Bookmark?
    
    func deleteAllBookmarks()
}
