import Foundation

class PlaylistUIState: PersistentStateProtocol {
    
    var view: String = "Tracks"
    
    required init?(_ map: NSDictionary) -> PlaylistUIState {
        
        let state = PlaylistUIState()
        
        if let viewName = map["view"] as? String {
            state.view = viewName
        }
        
        return state
    }
}

extension PlaylistViewState {
    
    static func initialize(_ persistentState: PlaylistUIState) {
        current = PlaylistType(rawValue: persistentState.view.lowercased()) ?? .tracks
    }
    
    static var persistentState: PlaylistUIState {
        
        let state = PlaylistUIState()
        state.view = current.rawValue.capitalizingFirstLetter()
        
        return state
    }
}
