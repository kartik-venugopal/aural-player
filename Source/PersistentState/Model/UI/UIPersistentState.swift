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
        
        self.windowLayout = map.objectValue(forKey: "windowLayout", ofType: WindowLayoutPersistentState.self)
        self.themes = map.objectValue(forKey: "themes", ofType: ThemesPersistentState.self)
        self.fontSchemes = map.objectValue(forKey: "fontSchemes", ofType: FontSchemesPersistentState.self)
        self.colorSchemes = map.objectValue(forKey: "colorSchemes", ofType: ColorSchemesPersistentState.self)
        self.player = map.objectValue(forKey: "player", ofType: PlayerUIPersistentState.self)
        self.playlist = map.objectValue(forKey: "playlist", ofType: PlaylistUIPersistentState.self)
        self.visualizer = map.objectValue(forKey: "visualizer", ofType: VisualizerUIPersistentState.self)
        self.windowAppearance = map.objectValue(forKey: "windowAppearance", ofType: WindowUIPersistentState.self)
        self.menuBarPlayer = map.objectValue(forKey: "menuBarPlayer", ofType: MenuBarPlayerUIPersistentState.self)
    }
}
