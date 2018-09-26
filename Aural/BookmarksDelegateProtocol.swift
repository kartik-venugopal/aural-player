import Foundation

protocol BookmarksDelegateProtocol {
    
    func addBookmark(_ name: String, _ file: URL, _ position: Double) -> Bookmark
    
    func getAllBookmarks() -> [Bookmark]
    
    func getBookmarkAtIndex(_ index: Int) -> Bookmark
    
    func deleteBookmarkAtIndex(_ index: Int)
    
    func deleteBookmarkWithName(_ name: String)
    
    func countBookmarks() -> Int
    
    func bookmarkWithNameExists(_ name: String) -> Bool
    
    func playBookmark(_ bookmark: Bookmark)
}
