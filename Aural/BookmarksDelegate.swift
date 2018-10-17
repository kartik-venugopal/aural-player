import Foundation

class BookmarksDelegate: BookmarksDelegateProtocol, PersistentModelObject {
    
    private let bookmarks: BookmarksProtocol
    
    // Delegate used to perform CRUD on the playlist
    private let playlist: PlaylistDelegateProtocol
    
    // Delegate used to perform playback
    private let player: PlaybackDelegateProtocol
    
    init(_ bookmarks: BookmarksProtocol, _ playlist: PlaylistDelegateProtocol, _ player: PlaybackDelegateProtocol, _ state: BookmarksState) {
        
        self.bookmarks = bookmarks
        self.playlist = playlist
        self.player = player
        
        // Restore the bookmarks model object from persistent state
        state.bookmarks.forEach({
            
            if let endPos = $0.endPosition {
                _ = bookmarks.addBookmark($0.name, $0.file, $0.startPosition, endPos)
            } else {
                _ = bookmarks.addBookmark($0.name, $0.file, $0.startPosition)
            }
        })
    }
    
    func addBookmark(_ name: String, _ file: URL, _ startPosition: Double) -> Bookmark {
        return bookmarks.addBookmark(name, file, startPosition)
    }
    
    func addBookmark(_ name: String, _ file: URL, _ startPosition: Double, _ endPosition: Double) -> Bookmark {
        return bookmarks.addBookmark(name, file, startPosition, endPosition)
    }
    
    func getAllBookmarks() -> [Bookmark] {
        return bookmarks.getAllBookmarks()
    }
    
    func countBookmarks() -> Int {
        return bookmarks.countBookmarks()
    }
    
    func getBookmarkAtIndex(_ index: Int) -> Bookmark {
        return bookmarks.getBookmarkAtIndex(index)
    }
    
    func bookmarkWithNameExists(_ name: String) -> Bool {
        return bookmarks.bookmarkWithNameExists(name)
    }
    
    func playBookmark(_ bookmark: Bookmark) {
        
        do {
            // First, find or add the given file
            let newTrack = try playlist.findOrAddFile(bookmark.file)
            
            // Play it immediately. Don't allow a gap/delay.
            let params = PlaybackParams().withStartAndEndPosition(bookmark.startPosition, bookmark.endPosition).withAllowDelay(false)
            player.play(newTrack.track, params)
            
        } catch let error {
            
            // TODO: Handle FileNotFoundError
            if let fnfError = error as? FileNotFoundError {
                NSLog("Unable to play Bookmark item. Details: %@", fnfError.message)
            }
        }
    }
    
    func deleteBookmarkAtIndex(_ index: Int) {
        bookmarks.deleteBookmarkAtIndex(index)
    }
    
    func deleteBookmarkWithName(_ name: String) {
        bookmarks.deleteBookmarkWithName(name)
    }
    
    func persistentState() -> PersistentState {
        
        let state = BookmarksState()
        
        bookmarks.getAllBookmarks().forEach({
            state.bookmarks.append(($0.name, $0.file, $0.startPosition, $0.endPosition))
        })
        
        return state
    }
}
