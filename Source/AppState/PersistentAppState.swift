import Cocoa

/*
 Encapsulates all application state. It is persisted to disk upon exit and loaded into the application upon startup.
 
 TODO: Make this class conform to different protocols for access/mutation
 */
class PersistentAppState: PersistentStateProtocol {
    
    var appVersion: String = ""
    var ui: UIState = UIState()
    var audioGraph: AudioGraphState = AudioGraphState()
    var playlist: PlaylistState = PlaylistState()
    var playbackSequence: PlaybackSequenceState = PlaybackSequenceState()
    
    var history: HistoryState = HistoryState()
    var favorites: [(file: URL, name: String)] = [(file: URL, name: String)]()
    var bookmarks: [BookmarkState] = []
    var playbackProfiles: [PlaybackProfile] = []
    var musicBrainzCache: MusicBrainzCacheState = MusicBrainzCacheState()
    var tuneBrowser: TuneBrowserPersistentState = TuneBrowserPersistentState()
    
    static let defaults: PersistentAppState = PersistentAppState()
    
    // Produces an AppState object from deserialized JSON
    static func deserialize(_ map: NSDictionary) -> PersistentAppState {
        
        let state = PersistentAppState()
        
        if let uiDict = (map["ui"] as? NSDictionary) {
            state.ui = UIState.deserialize(uiDict)
        }
        
        if let map = (map["audioGraph"] as? NSDictionary) {
            state.audioGraph = AudioGraphState.deserialize(map)
        }
        
        if let playbackSequenceDict = (map["playbackSequence"] as? NSDictionary) {
            state.playbackSequence = PlaybackSequenceState.deserialize(playbackSequenceDict)
        }
        
        if let playlistDict = (map["playlist"] as? NSDictionary) {
            state.playlist = PlaylistState.deserialize(playlistDict)
        }
        
        if let historyDict = (map["history"] as? NSDictionary) {
            state.history = HistoryState.deserialize(historyDict)
        }
        
        if let favoritesArr = map["favorites"] as? [NSDictionary] {
            
            favoritesArr.forEach {
                
                if let file = $0["file"] as? String, let name = $0["name"] as? String {
                    state.favorites.append((URL(fileURLWithPath: file), name))
                }
            }
        }
        
        (map["bookmarks"] as? NSArray)?.forEach({
            
            if let bookmarkDict = $0 as? NSDictionary, let bookmark = BookmarkState.deserialize(bookmarkDict) {
                state.bookmarks.append(bookmark)
            }
        })
        
        (map["playbackProfiles"] as? NSArray)?.forEach({
            
            if let dict = $0 as? NSDictionary, let profile = PlaybackProfile.deserialize(dict) {
                state.playbackProfiles.append(profile)
            }
        })
        
        if let musicBrainzCacheDict = map["musicBrainzCache"] as? NSDictionary {
            state.musicBrainzCache = MusicBrainzCacheState.deserialize(musicBrainzCacheDict)
        }
        
        if let tuneBrowserDict = map["tuneBrowser"] as? NSDictionary {
            state.tuneBrowser = TuneBrowserPersistentState.deserialize(tuneBrowserDict)
        }
        
        return state
    }
}
