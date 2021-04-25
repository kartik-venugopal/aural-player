import Cocoa

/*
    Encapsulates all application state. It is persisted to disk upon exit and loaded into the application upon startup.
 */
class PersistentAppState: PersistentStateProtocol {
    
    var appVersion: String?
    var ui: UIState?
    var audioGraph: AudioGraphState?
    var playlist: PlaylistState?
    var playbackSequence: PlaybackSequenceState?
    
    var history: HistoryState?
    var favorites: [FavoriteState]?
    var bookmarks: [BookmarkState]?
    var playbackProfiles: [PlaybackProfileState]?
    var musicBrainzCache: MusicBrainzCacheState?
    var tuneBrowser: TuneBrowserPersistentState?
    
    init() {}
    
    static let defaults: PersistentAppState = PersistentAppState()
    
    // Produces an AppState object from deserialized JSON
    required init?(_ map: NSDictionary) {
        
        self.ui = map.objectValue(forKey: "ui", ofType: UIState.self)

        self.audioGraph = map.objectValue(forKey: "audioGraph", ofType: AudioGraphState.self)
        self.playbackSequence = map.objectValue(forKey: "playbackSequence", ofType: PlaybackSequenceState.self)
        self.playlist = map.objectValue(forKey: "playlist", ofType: PlaylistState.self)
        self.playbackProfiles = map.arrayValue(forKey: "playbackProfiles", ofType: PlaybackProfileState.self)
        
        self.history = map.objectValue(forKey: "history", ofType: HistoryState.self)
        self.favorites = map.arrayValue(forKey: "favorites", ofType: FavoriteState.self)
        self.bookmarks = map.arrayValue(forKey: "bookmarks", ofType: BookmarkState.self)
        
        self.musicBrainzCache = map.objectValue(forKey: "musicBrainzCache", ofType: MusicBrainzCacheState.self)
        self.tuneBrowser = map.objectValue(forKey: "tuneBrowser", ofType: TuneBrowserPersistentState.self)
    }
}
