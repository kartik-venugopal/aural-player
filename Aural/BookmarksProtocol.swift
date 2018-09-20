import Foundation

protocol BookmarksProtocol {
    
    func addBookmark(_ name: String, _ file: URL, _ position: Double) -> Bookmark
    
    func getAllBookmarks() -> [Bookmark]
}
