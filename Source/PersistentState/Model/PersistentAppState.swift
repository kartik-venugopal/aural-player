import Cocoa

/*
    Encapsulates all application state. It is persisted to disk upon exit and loaded into the application upon startup.
 */
class PersistentAppState: PersistentStateProtocol {
    
    var appVersion: String?
    var ui: UIPersistentState?
    var audioGraph: AudioGraphPersistentState?
    var playlist: PlaylistPersistentState?
    var playbackSequence: PlaybackSequencePersistentState?
    
    var history: HistoryPersistentState?
    var favorites: [FavoritePersistentState]?
    var bookmarks: [BookmarkPersistentState]?
    var playbackProfiles: [PlaybackProfilePersistentState]?
    var musicBrainzCache: MusicBrainzCachePersistentState?
    var tuneBrowser: TuneBrowserPersistentState?
    
    init() {}
    
    static let defaults: PersistentAppState = PersistentAppState()
    
    // Produces an AppState object from deserialized JSON
    required init?(_ map: NSDictionary) {
        
        self.ui = map.objectValue(forKey: "ui", ofType: UIPersistentState.self)

        self.audioGraph = map.objectValue(forKey: "audioGraph", ofType: AudioGraphPersistentState.self)
        self.playbackSequence = map.objectValue(forKey: "playbackSequence", ofType: PlaybackSequencePersistentState.self)
        self.playlist = map.objectValue(forKey: "playlist", ofType: PlaylistPersistentState.self)
        self.playbackProfiles = map.arrayValue(forKey: "playbackProfiles", ofType: PlaybackProfilePersistentState.self)
        
        self.history = map.objectValue(forKey: "history", ofType: HistoryPersistentState.self)
        self.favorites = map.arrayValue(forKey: "favorites", ofType: FavoritePersistentState.self)
        self.bookmarks = map.arrayValue(forKey: "bookmarks", ofType: BookmarkPersistentState.self)
        
        self.musicBrainzCache = map.objectValue(forKey: "musicBrainzCache", ofType: MusicBrainzCachePersistentState.self)
        self.tuneBrowser = map.objectValue(forKey: "tuneBrowser", ofType: TuneBrowserPersistentState.self)
    }
}
