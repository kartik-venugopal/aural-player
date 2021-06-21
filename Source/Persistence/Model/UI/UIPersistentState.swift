import Cocoa

/*
    Encapsulates UI state
 */
class UIPersistentState: PersistentStateProtocol {
    
    var appMode: AppMode?
    var windowLayout: WindowLayoutPersistentState?
    var themes: ThemesPersistentState?
    var fontSchemes: FontSchemesPersistentState?
    var colorSchemes: ColorSchemesPersistentState?
    var player: PlayerUIPersistentState?
    var playlist: PlaylistUIPersistentState?
    var visualizer: VisualizerUIPersistentState?
    var windowAppearance: WindowUIPersistentState?
    
    var menuBarPlayer: MenuBarPlayerUIPersistentState?
    
    init() {}
    
    required init?(_ map: NSDictionary) {
        
        self.appMode = map.enumValue(forKey: "appMode", ofType: AppMode.self)
        
        self.windowLayout = map.persistentObjectValue(forKey: "windowLayout", ofType: WindowLayoutPersistentState.self)
        self.themes = map.persistentObjectValue(forKey: "themes", ofType: ThemesPersistentState.self)
        self.fontSchemes = map.persistentObjectValue(forKey: "fontSchemes", ofType: FontSchemesPersistentState.self)
        self.colorSchemes = map.persistentObjectValue(forKey: "colorSchemes", ofType: ColorSchemesPersistentState.self)
        self.player = map.persistentObjectValue(forKey: "player", ofType: PlayerUIPersistentState.self)
        self.playlist = map.persistentObjectValue(forKey: "playlist", ofType: PlaylistUIPersistentState.self)
        self.visualizer = map.persistentObjectValue(forKey: "visualizer", ofType: VisualizerUIPersistentState.self)
        self.windowAppearance = map.persistentObjectValue(forKey: "windowAppearance", ofType: WindowUIPersistentState.self)
        self.menuBarPlayer = map.persistentObjectValue(forKey: "menuBarPlayer", ofType: MenuBarPlayerUIPersistentState.self)
    }
}
