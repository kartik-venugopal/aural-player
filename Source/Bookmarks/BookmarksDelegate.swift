import Foundation

fileprivate typealias Bookmarks = MappedPresets<Bookmark>

class BookmarksDelegate: BookmarksDelegateProtocol {
    
    private let bookmarks: Bookmarks
    
    // Delegate used to perform CRUD on the playlist
    private let playlist: PlaylistDelegateProtocol
    
    // Delegate used to perform playback
    private let player: PlaybackDelegateProtocol
    
    init(persistentState: [BookmarkPersistentState]?, _ playlist: PlaylistDelegateProtocol, _ player: PlaybackDelegateProtocol) {
        
        self.playlist = playlist
        self.player = player
        
        // Restore the bookmarks model object from persistent state
        let allBookmarks: [Bookmark] = persistentState?.map {Bookmark($0.name, $0.file, $0.startPosition, $0.endPosition)} ?? []
        self.bookmarks = Bookmarks(systemDefinedPresets: [], userDefinedPresets: allBookmarks)
    }
    
    func addBookmark(_ name: String, _ track: Track, _ startPosition: Double, _ endPosition: Double? = nil) -> Bookmark {
        
        let newBookmark = Bookmark(name, track.file, startPosition, endPosition)
        bookmarks.addPreset(newBookmark)
        return newBookmark
    }
    
    var allBookmarks: [Bookmark] {
        return bookmarks.userDefinedPresets
    }
    
    var count: Int {
        return bookmarks.numberOfUserDefinedPresets
    }
    
    func getBookmarkAtIndex(_ index: Int) -> Bookmark {
        return bookmarks.userDefinedPresets[index]
    }
    
    func bookmarkWithNameExists(_ name: String) -> Bool {
        return bookmarks.presetExists(named: name)
    }
    
    func playBookmark(_ bookmark: Bookmark) throws {
        
        do {
            // First, find or add the given file
            if let newTrack = try playlist.findOrAddFile(bookmark.file) {
            
                // Play it.
                let params = PlaybackParams().withStartAndEndPosition(bookmark.startPosition, bookmark.endPosition)
                player.play(newTrack, params)
            }
            
        } catch {
            
            if let fnfError = error as? FileNotFoundError {
                
                // Log and rethrow error
                NSLog("Unable to play Bookmark item. Details: %@", fnfError.message)
                throw fnfError
            }
        }
    }
    
    func renameBookmarkAtIndex(_ index: Int, _ newName: String) {
        
        let bookmark = bookmarks.userDefinedPresets[index]
        bookmarks.renamePreset(named: bookmark.name, to: newName)
    }
    
    func deleteBookmarkAtIndex(_ index: Int) {
        bookmarks.deletePreset(atIndex: index)
    }
    
    func deleteBookmarkWithName(_ name: String) {
        bookmarks.deletePreset(named: name)
    }
    
    var persistentState: [BookmarkPersistentState] {
        allBookmarks.map {BookmarkPersistentState($0.name, $0.file, $0.startPosition, $0.endPosition)}
    }
}
