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
    
    init() {}
    
    static let defaults: PersistentAppState = PersistentAppState()
    
    // Produces an AppState object from deserialized JSON
    required init?(_ map: NSDictionary) {
        
        self.ui = map.persistentObjectValue(forKey: "ui", ofType: UIPersistentState.self)

        self.audioGraph = map.persistentObjectValue(forKey: "audioGraph", ofType: AudioGraphPersistentState.self)
        self.playbackSequence = map.persistentObjectValue(forKey: "playbackSequence", ofType: PlaybackSequencePersistentState.self)
        self.playlist = map.persistentObjectValue(forKey: "playlist", ofType: PlaylistPersistentState.self)
        self.playbackProfiles = map.persistentObjectArrayValue(forKey: "playbackProfiles", ofType: PlaybackProfilePersistentState.self)
        
        self.history = map.persistentObjectValue(forKey: "history", ofType: HistoryPersistentState.self)
        self.favorites = map.persistentObjectArrayValue(forKey: "favorites", ofType: FavoritePersistentState.self)
        self.bookmarks = map.persistentObjectArrayValue(forKey: "bookmarks", ofType: BookmarkPersistentState.self)
        
        self.musicBrainzCache = map.persistentObjectValue(forKey: "musicBrainzCache", ofType: MusicBrainzCachePersistentState.self)
    }
}
