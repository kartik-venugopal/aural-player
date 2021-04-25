import Foundation

class BookmarksDelegate: BookmarksDelegateProtocol {
    
    let bookmarks: BookmarksProtocol
    
    // Delegate used to perform CRUD on the playlist
    private let playlist: PlaylistDelegateProtocol
    
    // Delegate used to perform playback
    private let player: PlaybackDelegateProtocol
    
    init(persistentState: [BookmarkState]?, _ bookmarks: BookmarksProtocol, _ playlist: PlaylistDelegateProtocol, _ player: PlaybackDelegateProtocol) {
        
        self.bookmarks = bookmarks
        self.playlist = playlist
        self.player = player
        
        // Restore the bookmarks model object from persistent state
        persistentState?.forEach {
            _ = bookmarks.addBookmark($0.name, $0.file, $0.startPosition, $0.endPosition)
        }
    }
    
    func addBookmark(_ name: String, _ track: Track, _ startPosition: Double, _ endPosition: Double? = nil) -> Bookmark {
        return bookmarks.addBookmark(name, track.file, startPosition, endPosition)
    }
    
    var allBookmarks: [Bookmark] {
        return bookmarks.allBookmarks
    }
    
    var count: Int {
        return bookmarks.count
    }
    
    func getBookmarkAtIndex(_ index: Int) -> Bookmark {
        return bookmarks.getBookmarkAtIndex(index)
    }
    
    func bookmarkWithNameExists(_ name: String) -> Bool {
        return bookmarks.bookmarkWithNameExists(name)
    }
    
    func playBookmark(_ bookmark: Bookmark) throws {
        
        do {
            // First, find or add the given file
            if let newTrack = try playlist.findOrAddFile(bookmark.file) {
            
                // Play it.
                let params = PlaybackParams().withStartAndEndPosition(bookmark.startPosition, bookmark.endPosition)
                player.play(newTrack, params)
            }
            
        } catch let error {
            
            if let fnfError = error as? FileNotFoundError {
                
                // Log and rethrow error
                NSLog("Unable to play Bookmark item. Details: %@", fnfError.message)
                throw fnfError
            }
        }
    }
    
    func renameBookmarkAtIndex(_ index: Int, _ newName: String) {
        bookmarks.renameBookmarkAtIndex(index, newName)
    }
    
    func deleteBookmarkAtIndex(_ index: Int) {
        bookmarks.deleteBookmarkAtIndex(index)
    }
    
    func deleteBookmarkWithName(_ name: String) {
        bookmarks.deleteBookmarkWithName(name)
    }
}
