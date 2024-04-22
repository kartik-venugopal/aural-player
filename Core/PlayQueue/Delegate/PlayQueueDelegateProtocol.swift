import Foundation

protocol PlayQueueDelegateProtocol: TrackListProtocol, SequencingProtocol, HistoryDelegateProtocol {
    
    func initialize(fromPersistentState persistentState: PlayQueuePersistentState?, appLaunchFiles: [URL])
    
    var currentTrack: Track? {get}
    
    var currentTrackIndex: Int? {get}
    
    // MARK: Mutating functions ---------------------------------------------------------------
    
    // Tracks loaded directly from the file system (either Finder or on startup)
    func loadTracks(from urls: [URL], atPosition position: Int?, params: PlayQueueTrackLoadParams)
    
    // MARK: Play Now ---------------------------------------------------------------
    
    // Library (Tracks view) / Managed Playlists / Favorites / Bookmarks / History
    @discardableResult func enqueueToPlayNow(tracks: [Track], clearQueue: Bool, params: PlaybackParams) -> IndexSet
    
    // Library (grouped views) / Favorites / History
//    @discardableResult func enqueueToPlayNow(groups: [Group], tracks: [Track], clearQueue: Bool, params: PlaybackParams) -> IndexSet
    
    // Library (playlist files)
//    @discardableResult func enqueueToPlayNow(playlistFiles: [ImportedPlaylist], tracks: [Track], clearQueue: Bool, params: PlaybackParams) -> IndexSet
    
    // Library (Managed Playlist)
//    @discardableResult func enqueueToPlayNow(playlist: Playlist, clearQueue: Bool, params: PlaybackParams) -> IndexSet
    
    // Tune Browser
//    @discardableResult func enqueueToPlayNow(fileSystemItems: [FileSystemItem], clearQueue: Bool, params: PlaybackParams) -> IndexSet
    
    // MARK: Play Next ---------------------------------------------------------------
    
    // Inserts tracks immediately after the current track, i.e. "Play Next"
    
    @discardableResult func enqueueToPlayNext(tracks: [Track]) -> IndexSet
    
//    @discardableResult func enqueueToPlayNext(groups: [Group], tracks: [Track]) -> IndexSet
//    
//    @discardableResult func enqueueToPlayNext(playlistFiles: [ImportedPlaylist], tracks: [Track]) -> IndexSet
//    
//    @discardableResult func enqueueToPlayNext(playlist: Playlist) -> IndexSet
//    
//    @discardableResult func enqueueToPlayNext(fileSystemItems: [FileSystemItem]) -> IndexSet
    
    // Moves tracks immediately after the current track, i.e. "Play Next"
    @discardableResult func moveTracksToPlayNext(from indices: IndexSet) -> IndexSet
    
    // MARK: Play Later ---------------------------------------------------------------
    
    @discardableResult func enqueueToPlayLater(tracks: [Track]) -> IndexSet
    
//    @discardableResult func enqueueToPlayLater(groups: [Group], tracks: [Track]) -> IndexSet
//    
//    @discardableResult func enqueueToPlayLater(playlistFiles: [ImportedPlaylist], tracks: [Track]) -> IndexSet
//    
//    @discardableResult func enqueueToPlayLater(playlist: Playlist) -> IndexSet
//    
//    @discardableResult func enqueueToPlayLater(fileSystemItems: [FileSystemItem]) -> IndexSet
}

extension PlayQueueDelegateProtocol {
    
    @discardableResult func enqueueToPlayNow(tracks: [Track], clearQueue: Bool, params: PlaybackParams = .defaultParams()) -> IndexSet {
        enqueueToPlayNow(tracks: tracks, clearQueue: clearQueue, params: params)
    }
    
//    @discardableResult func enqueueToPlayNow(group: Group, clearQueue: Bool, params: PlaybackParams = .defaultParams()) -> IndexSet {
//        enqueueToPlayNow(groups: [group], tracks: [], clearQueue: clearQueue, params: params)
//    }
//    
//    @discardableResult func enqueueToPlayNow(playlistFile: ImportedPlaylist, clearQueue: Bool, params: PlaybackParams = .defaultParams()) -> IndexSet {
//        enqueueToPlayNow(playlistFiles: [playlistFile], tracks: [], clearQueue: clearQueue, params: params)
//    }
//    
//    @discardableResult func enqueueToPlayNow(fileSystemItems: [FileSystemItem], clearQueue: Bool, params: PlaybackParams = .defaultParams()) -> IndexSet {
//        enqueueToPlayNow(fileSystemItems: fileSystemItems, clearQueue: clearQueue, params: params)
//    }
//    
//    @discardableResult func enqueueToPlayNow(playlist: Playlist, clearQueue: Bool, params: PlaybackParams = .defaultParams()) -> IndexSet {
//        enqueueToPlayNow(playlist: playlist, clearQueue: clearQueue, params: params)
//    }
    
//    @discardableResult func enqueueToPlayNow(group: Group, clearQueue: Bool) -> IndexSet {
//        enqueueToPlayNow(groups: [group], tracks: [], clearQueue: clearQueue, params: .defaultParams())
//    }
//    
//    @discardableResult func enqueueToPlayNow(playlistFile: ImportedPlaylist, clearQueue: Bool) -> IndexSet {
//        enqueueToPlayNow(playlistFiles: [playlistFile], tracks: [], clearQueue: clearQueue, params: .defaultParams())
//    }
    
//    @discardableResult func enqueueToPlayLater(group: Group) -> IndexSet {
//        enqueueToPlayLater(groups: [group], tracks: [])
//    }
//    
//    @discardableResult func enqueueToPlayLater(playlistFile: ImportedPlaylist) -> IndexSet {
//        enqueueToPlayLater(playlistFiles: [playlistFile], tracks: [])
//    }
    
    func loadTracks(from urls: [URL]) {
        loadTracks(from: urls, atPosition: nil, params: .defaultParams)
    }
    
    func loadTracks(from urls: [URL], atPosition position: Int?) {
        loadTracks(from: urls, atPosition: position, params: .defaultParams)
    }
    
    func loadTracks(from urls: [URL], params: PlayQueueTrackLoadParams) {
        loadTracks(from: urls, atPosition: nil, params: params)
    }
}
