import Foundation

/*
 Encapsulates playlist state
 */
class PlaylistState: PersistentState {
    
    // List of track files
    var tracks: [URL] = [URL]()
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = PlaylistState()
        
        (map["tracks"] as? [String])?.forEach({state.tracks.append(URL(fileURLWithPath: $0))})
        
        return state
    }
}

extension Playlist: PersistentModelObject {
    
    // Returns all state for this playlist that needs to be persisted to disk
    var persistentState: PersistentState {
        
        let state = PlaylistState()
        state.tracks = tracks.map {$0.file}
        return state
    }
}
