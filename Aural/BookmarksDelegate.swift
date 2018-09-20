import Foundation

class BookmarksDelegate: BookmarksDelegateProtocol {
    
    private let bookmarks: BookmarksProtocol
    
    // Delegate used to perform CRUD on the playlist
    private let playlist: PlaylistDelegateProtocol
    
    // Delegate used to perform playback
    private let player: PlaybackDelegateProtocol
    
    init(_ bookmarks: BookmarksProtocol, _ playlist: PlaylistDelegateProtocol, _ player: PlaybackDelegateProtocol) {
        
        self.bookmarks = bookmarks
        self.playlist = playlist
        self.player = player
        
        // Restore the bookmarks model object from persistent state
        
    }
    
    func addBookmark(_ name: String) -> Bookmark {
        
        let track = player.getPlayingTrack()!.track
        let position = player.getSeekPosition().timeElapsed
        
        let theName = String(format: "%@ (%@)", track.conciseDisplayName, StringUtils.formatSecondsToHMS(position))
        
        return bookmarks.addBookmark(theName, track, position)
    }
    
    func getAllBookmarks() -> [Bookmark] {
        return bookmarks.getAllBookmarks()
    }
    
    func playBookmark(_ bookmark: Bookmark) {
        
        let oldTrack = player.getPlayingTrack()
        
        do {
            // First, find or add the given file
            let newTrack = try playlist.findOrAddFile(bookmark.track.file)
            
            // Try playing it
            try _ = player.play(newTrack.track, bookmark.position, PlaylistViewState.current)
            
            // Notify the UI that a track has started playing
            AsyncMessenger.publishMessage(TrackChangedAsyncMessage(oldTrack, newTrack))
            
        } catch let error {
            
            if (error is InvalidTrackError) {
                AsyncMessenger.publishMessage(TrackNotPlayedAsyncMessage(oldTrack, error as! InvalidTrackError))
            }
        }
    }
}
