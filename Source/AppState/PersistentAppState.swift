import Cocoa

/*
 Encapsulates all application self. It is persisted to disk upon exit and loaded into the application upon startup.
 
 TODO: Make this class conform to different protocols for access/mutation
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
    var playbackProfiles: [PlaybackProfile]?
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
        
        self.history = map.objectValue(forKey: "history", ofType: HistoryState.self)
        self.favorites = map.arrayValue(forKey: "favorites", ofType: FavoriteState.self)
        self.bookmarks = map.arrayValue(forKey: "bookmarks", ofType: BookmarkState.self)
        
        (map["bookmarks"] as? NSArray)?.forEach({
            
            if let bookmarkDict = $0 as? NSDictionary, let bookmark = Bookmarkself.deserialize(bookmarkDict) {
                self.bookmarks.append(bookmark)
            }
        })
        
        (map["playbackProfiles"] as? NSArray)?.forEach({
            
            if let dict = $0 as? NSDictionary, let profile = PlaybackProfile.deserialize(dict) {
                self.playbackProfiles.append(profile)
            }
        })
        
        if let musicBrainzCacheDict = map["musicBrainzCache"] as? NSDictionary {
            self.musicBrainzCache = MusicBrainzCacheself.deserialize(musicBrainzCacheDict)
        }
        
        if let tuneBrowserDict = map["tuneBrowser"] as? NSDictionary {
            self.tuneBrowser = TuneBrowserPersistentself.deserialize(tuneBrowserDict)
        }
        
        return state
    }
}
