import Foundation

class PlaylistUIPersistentState: PersistentStateProtocol {
    
    var view: PlaylistType?
    
    init(view: PlaylistType) {
        self.view = view
    }
    
    required init?(_ map: NSDictionary) {
        self.view = map.enumValue(forKey: "view", ofType: PlaylistType.self)
    }
}

extension PlaylistViewState {
    
    static func initialize(_ persistentState: PlaylistUIPersistentState?) {
        currentView = persistentState?.view ?? PlaylistViewDefaults.currentView
    }
    
    static var persistentState: PlaylistUIPersistentState {
        PlaylistUIPersistentState(view: currentView)
    }
}
