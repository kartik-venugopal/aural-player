import Foundation

protocol BookmarksProtocol {
    
    func addBookmark(_ name: String, _ track: Track, _ position: Double) -> Bookmark
    
    func getAllBookmarks() -> [Bookmark]
}
