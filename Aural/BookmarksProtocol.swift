import Foundation

protocol BookmarksProtocol {
    
    func addBookmark(_ name: String, _ file: URL, _ startPosition: Double) -> Bookmark
    
    func addBookmark(_ name: String, _ file: URL, _ startPosition: Double, _ endPosition: Double) -> Bookmark
    
    func getAllBookmarks() -> [Bookmark]
    
    func getBookmarkAtIndex(_ index: Int) -> Bookmark
    
    func deleteBookmarkAtIndex(_ index: Int)
    
    func deleteBookmarkWithName(_ name: String)
    
    func countBookmarks() -> Int
    
    func bookmarkWithNameExists(_ name: String) -> Bool
    
    func getBookmarkWithName(_ name: String) -> Bookmark?
    
    func deleteAllBookmarks()
}
