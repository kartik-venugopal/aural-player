import Cocoa

/*
 Encapsulates all application state. It is persisted to disk upon exit and loaded into the application upon startup.
 
 TODO: Make this class conform to different protocols for access/mutation
 */
class AppState {
    
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
    
    static let defaults: AppState = AppState()
    
    // Produces an AppState object from deserialized JSON
    static func deserialize(_ jsonObject: NSDictionary) -> AppState {
        
        let state = AppState()
        
        if let uiDict = (jsonObject["ui"] as? NSDictionary) {
            state.ui = UIState.deserialize(uiDict) as! UIState
        }
        
        if let map = (jsonObject["audioGraph"] as? NSDictionary) {
            state.audioGraph = AudioGraphState.deserialize(map) as! AudioGraphState
        }
        
        if let playbackSequenceDict = (jsonObject["playbackSequence"] as? NSDictionary) {
            state.playbackSequence = PlaybackSequenceState.deserialize(playbackSequenceDict) as! PlaybackSequenceState
        }
        
        if let playlistDict = (jsonObject["playlist"] as? NSDictionary) {
            state.playlist = PlaylistState.deserialize(playlistDict) as! PlaylistState
        }
        
        if let historyDict = (jsonObject["history"] as? NSDictionary) {
            state.history = HistoryState.deserialize(historyDict) as! HistoryState
        }
        
        if let favoritesArr = (jsonObject["favorites"] as? [NSDictionary]) {
            favoritesArr.forEach({
                if let file = $0["file"] as? String, let name = $0["name"] as? String {
                    state.favorites.append((URL(fileURLWithPath: file), name))
                }
            })
        }
        
        (jsonObject["bookmarks"] as? NSArray)?.forEach({
            
            if let bookmarkDict = $0 as? NSDictionary, let bookmark = BookmarkState.deserialize(bookmarkDict) {
                state.bookmarks.append(bookmark)
            }
        })
        
        (jsonObject["playbackProfiles"] as? NSArray)?.forEach({
            
            if let dict = $0 as? NSDictionary, let profile = PlaybackProfile.deserialize(dict) {
                state.playbackProfiles.append(profile)
            }
        })
        
        if let musicBrainzCacheDict = (jsonObject["musicBrainzCache"] as? NSDictionary) {
            state.musicBrainzCache = MusicBrainzCacheState.deserialize(musicBrainzCacheDict) as! MusicBrainzCacheState
        }
        
        return state
    }
}
