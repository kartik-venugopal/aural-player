import Foundation

protocol BookmarksDelegateProtocol {
    
    func addBookmark(_ name: String) -> Bookmark
    
    func getAllBookmarks() -> [Bookmark]
    
    func playBookmark(_ bookmark: Bookmark)
}
