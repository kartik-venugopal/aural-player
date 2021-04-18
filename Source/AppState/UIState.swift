import Cocoa

/*
 Encapsulates UI state
 */
class UIState: PersistentStateProtocol {
    
    var windowLayout: WindowLayoutPersistentState = WindowLayoutPersistentState()
    var themes: ThemesState = ThemesState()
    var fontSchemes: FontSchemesState = FontSchemesState()
    var colorSchemes: ColorSchemesState = ColorSchemesState()
    var player: PlayerUIState = PlayerUIState()
    var playlist: PlaylistUIState = PlaylistUIState()
    var visualizer: VisualizerUIState = VisualizerUIState()
    var windowAppearance: WindowUIState = WindowUIState()
    
    var statusBarPlayer: StatusBarPlayerUIState = StatusBarPlayerUIState()
    
    static func deserialize(_ map: NSDictionary) -> UIState {
        
        let state = UIState()
        
        if let windowLayoutMap = map["windowLayout"] as? NSDictionary {
            state.windowLayout = WindowLayoutPersistentState.deserialize(windowLayoutMap)
        }
        
        if let themesMap = map["themes"] as? NSDictionary {
            state.themes = ThemesState.deserialize(themesMap)
        }
        
        if let fontSchemesMap = map["fontSchemes"] as? NSDictionary {
            state.fontSchemes = FontSchemesState.deserialize(fontSchemesMap)
        }
        
        if let colorSchemesMap = map["colorSchemes"] as? NSDictionary {
            state.colorSchemes = ColorSchemesState.deserialize(colorSchemesMap)
        }
        
        if let playerMap = map["player"] as? NSDictionary {
            state.player = PlayerUIState.deserialize(playerMap)
        }
        
        if let playlistMap = map["playlist"] as? NSDictionary {
            state.playlist = PlaylistUIState.deserialize(playlistMap)
        }
        
        if let visualizerMap = map["visualizer"] as? NSDictionary {
            state.visualizer = VisualizerUIState.deserialize(visualizerMap)
        }
        
        if let windowAppearanceMap = map["windowAppearance"] as? NSDictionary {
            state.windowAppearance = WindowUIState.deserialize(windowAppearanceMap)
        }
        
        if let statusBarPlayerMap = map["statusBarPlayer"] as? NSDictionary {
            state.statusBarPlayer = StatusBarPlayerUIState.deserialize(statusBarPlayerMap)
        }
        
        return state
    }
}
