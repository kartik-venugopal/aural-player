import Cocoa

// Marks an object as having state that needs to be persisted
protocol PersistentModelObject {
    
    // Retrieves persistent state for this model object
    var persistentState: PersistentState {get}
}

// Marks an object as being suitable for persistence, i.e. it is serializable/deserializable
protocol PersistentState {
    
    // Constructs an instance of this state object from the given map
    static func deserialize(_ map: NSDictionary) -> PersistentState
}

/*
    Encapsulates an audio output device (remembered device)
 */
class AudioDeviceState: PersistentState {
    
    var name: String = ""
    var uid: String = ""
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state: AudioDeviceState = AudioDeviceState()
        
        if let name = (map["name"] as? String) {
            state.name = name
        }
        
        if let uid = (map["uid"] as? String) {
            state.uid = uid
        }
        
        return state
    }
}

/*
    Encapsulates playback sequence state
 */
class PlaybackSequenceState: PersistentState {
    
    var repeatMode: RepeatMode = AppDefaults.repeatMode
    var shuffleMode: ShuffleMode = AppDefaults.shuffleMode
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = PlaybackSequenceState()
        
        state.repeatMode = mapEnum(map, "repeatMode", AppDefaults.repeatMode)
        state.shuffleMode = mapEnum(map, "shuffleMode", AppDefaults.shuffleMode)
        
        return state
    }
}

class HistoryState: PersistentState {
    
    var recentlyAdded: [(file: URL, name: String, time: Date)] = [(file: URL, name: String, time: Date)]()
    var recentlyPlayed: [(file: URL, name: String, time: Date)] = [(file: URL, name: String, time: Date)]()
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = HistoryState()
        
        if let recentlyAdded = map["recentlyAdded"] as? [NSDictionary] {
            recentlyAdded.forEach({if let item = deserializeHistoryItem($0) {state.recentlyAdded.append(item)}})
        }
        
        if let recentlyPlayed = map["recentlyPlayed"] as? [NSDictionary] {
            recentlyPlayed.forEach({if let item = deserializeHistoryItem($0) {state.recentlyPlayed.append(item)}})
        }
        
        return state
    }
    
    private static func deserializeHistoryItem(_ map: NSDictionary) -> (file: URL, name: String, time: Date)? {
        
        if let file = map["file"] as? String, let name = map["name"] as? String, let timestamp = map["time"] as? String {
            return (URL(fileURLWithPath: file), name, Date.fromString(timestamp))
        }
        
        return nil
    }
}

class BookmarkState {
    
    var name: String = ""
    var file: URL
    var startPosition: Double = 0
    var endPosition: Double?
    
    init(_ name: String, _ file: URL, _ startPosition: Double, _ endPosition: Double?) {
        self.name = name
        self.file = file
        self.startPosition = startPosition
        self.endPosition = endPosition
    }
    
    static func deserialize(_ bookmarkMap: NSDictionary) -> BookmarkState? {
        
        if let name = bookmarkMap["name"] as? String, let file = bookmarkMap["file"] as? String {
            
            let startPosition: Double = mapNumeric(bookmarkMap, "startPosition", AppDefaults.lastTrackPosition)
            let endPosition: Double? = mapNumeric(bookmarkMap, "endPosition")
            return BookmarkState(name, URL(fileURLWithPath: file), startPosition, endPosition)
        }
        
        return nil
    }
}

extension PlaybackProfile {
    
    static func deserialize(_ map: NSDictionary) -> PlaybackProfile? {
        
        var profileFile: URL?
        var profileLastPosition: Double = AppDefaults.lastTrackPosition
        
        if let file = map["file"] as? String {
            profileFile = URL(fileURLWithPath: file)
            profileLastPosition = mapNumeric(map, "lastPosition", AppDefaults.lastTrackPosition)
            return PlaybackProfile(profileFile!, profileLastPosition)
        }
        
        return nil
    }
}

class TranscoderState: PersistentState {
    
    var entries: [URL: URL] = [:]
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = TranscoderState()
        
        if let entries = map["entries"] as? NSDictionary {
            
            for (inFilePath, outFilePath) in entries {
                
                let inFile = URL(fileURLWithPath: String(describing: inFilePath))
                let outFile = URL(fileURLWithPath: String(describing: outFilePath))
                state.entries[inFile] = outFile
            }
        }
        
        return state
    }
}

/*
 Encapsulates all application state. It is persisted to disk upon exit and loaded into the application upon startup.
 
 TODO: Make this class conform to different protocols for access/mutation
 */
class AppState {
    
    var ui: UIState = UIState()
    var audioGraph: AudioGraphState = AudioGraphState()
    var playlist: PlaylistState = PlaylistState()
    var playbackSequence: PlaybackSequenceState = PlaybackSequenceState()
    var transcoder: TranscoderState = TranscoderState()
    
    var history: HistoryState = HistoryState()
    var favorites: [(file: URL, name: String)] = [(file: URL, name: String)]()
    var bookmarks: [BookmarkState] = []
    var playbackProfiles: [PlaybackProfile] = []
    
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
        
        if let transcoderDict = (jsonObject["transcoder"] as? NSDictionary) {
            state.transcoder = TranscoderState.deserialize(transcoderDict) as! TranscoderState
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
        
        return state
    }
}
