import Foundation

class PlaylistUIState: PersistentState {
    
    var view: String = "Tracks"
    
    static func deserialize(_ map: NSDictionary) -> PlaylistUIState {
        
        let state = PlaylistUIState()
        
        if let viewName = map["view"] as? String {
            state.view = viewName
        }
        
        return state
    }
}

extension PlaylistViewState {
    
    static func initialize(_ appState: PlaylistUIState) {
        current = PlaylistType(rawValue: appState.view.lowercased()) ?? .tracks
    }
    
    static var persistentState: PlaylistUIState {
        
        let state = PlaylistUIState()
        state.view = current.rawValue.capitalizingFirstLetter()
        
        return state
    }
}
