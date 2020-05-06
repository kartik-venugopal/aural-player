import Foundation

protocol BookmarksDelegateProtocol {

    // If the endPosition parameter is nil, it means a single track position is being bookmarked. Otherwise, a loop is being bookmarked.
    func addBookmark(_ name: String, _ track: Track, _ startPosition: Double, _ endPosition: Double?) -> Bookmark
    
    var allBookmarks: [Bookmark] {get}
    
    var count: Int {get}
    
    func getBookmarkAtIndex(_ index: Int) -> Bookmark
    
    func renameBookmarkAtIndex(_ index: Int, _ newName: String)
    
    func deleteBookmarkAtIndex(_ index: Int)
    
    func deleteBookmarkWithName(_ name: String)
    
    func bookmarkWithNameExists(_ name: String) -> Bool
    
    func playBookmark(_ bookmark: Bookmark) throws
}
