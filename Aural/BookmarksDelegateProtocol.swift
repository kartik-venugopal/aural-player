import Foundation

protocol BookmarksDelegateProtocol {
    
    func addBookmark(_ name: String, _ file: URL, _ position: Double) -> Bookmark
    
    func getAllBookmarks() -> [Bookmark]
    
    func getBookmarkAtIndex(_ index: Int) -> Bookmark?
    
    func countBookmarks() -> Int
    
    func bookmarkWithNameExists(_ name: String) -> Bool
    
    func playBookmark(_ bookmark: Bookmark)
    
    func deleteBookmark(_ name: String)
}
