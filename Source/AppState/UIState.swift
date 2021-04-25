import Cocoa

/*
    Encapsulates UI state
 */
class UIState: PersistentStateProtocol {
    
    var appMode: AppMode?
    var windowLayout: WindowLayoutPersistentState?
    var themes: ThemesState?
    var fontSchemes: FontSchemesState?
    var colorSchemes: ColorSchemesState?
    var player: PlayerUIState?
    var playlist: PlaylistUIState?
    var visualizer: VisualizerUIState?
    var windowAppearance: WindowUIState?
    
    var menuBarPlayer: MenuBarPlayerUIState?
    
    init() {}
    
    required init?(_ map: NSDictionary) {
        
        self.appMode = map.enumValue(forKey: "appMode", ofType: AppMode.self)
        
        self.windowLayout = map.objectValue(forKey: "windowLayout", ofType: WindowLayoutPersistentState.self)
        self.themes = map.objectValue(forKey: "themes", ofType: ThemesState.self)
        self.fontSchemes = map.objectValue(forKey: "fontSchemes", ofType: FontSchemesState.self)
        self.colorSchemes = map.objectValue(forKey: "colorSchemes", ofType: ColorSchemesState.self)
        self.player = map.objectValue(forKey: "player", ofType: PlayerUIState.self)
        self.playlist = map.objectValue(forKey: "playlist", ofType: PlaylistUIState.self)
        self.visualizer = map.objectValue(forKey: "visualizer", ofType: VisualizerUIState.self)
        self.windowAppearance = map.objectValue(forKey: "windowAppearance", ofType: WindowUIState.self)
        self.menuBarPlayer = map.objectValue(forKey: "menuBarPlayer", ofType: MenuBarPlayerUIState.self)
    }
}
