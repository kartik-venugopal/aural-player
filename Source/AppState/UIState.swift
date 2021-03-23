import Cocoa

/*
 Encapsulates UI state
 */
class UIState: PersistentState {
    
    var windowLayout: WindowLayoutState = WindowLayoutState()
    var fontSchemes: FontSchemesState = FontSchemesState()
    var colorSchemes: ColorSchemesState = ColorSchemesState()
    var player: PlayerUIState = PlayerUIState()
    var playlist: PlaylistUIState = PlaylistUIState()
    var visualizer: VisualizerUIState = VisualizerUIState()
    
    static func deserialize(_ map: NSDictionary) -> UIState {
        
        let state = UIState()
        
        if let windowLayoutMap = map["windowLayout"] as? NSDictionary {
            state.windowLayout = WindowLayoutState.deserialize(windowLayoutMap)
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
        
        return state
    }
}

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

class VisualizerUIState: PersistentState {
    
    var type: String?
    var options: VisualizerOptionsState?
    
    static func deserialize(_ map: NSDictionary) -> VisualizerUIState {
        
        let state = VisualizerUIState()
        
        if let type = map["type"] as? String {
            state.type = type
        }
        
        if let optionsDict = map["options"] as? NSDictionary {
            state.options = VisualizerOptionsState.deserialize(optionsDict)
        }
        
        return state
    }
}

class VisualizerOptionsState: PersistentState {
    
    var lowAmplitudeColor: ColorState?
    var highAmplitudeColor: ColorState?
    
    static func deserialize(_ map: NSDictionary) -> VisualizerOptionsState {
        
        let state = VisualizerOptionsState()
        
        if let colorDict = map["lowAmplitudeColor"] as? NSDictionary {
            state.lowAmplitudeColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["highAmplitudeColor"] as? NSDictionary {
            state.highAmplitudeColor = ColorState.deserialize(colorDict)
        }
        
        return state
    }
}

class PlayerUIState: PersistentState {
    
    var viewType: PlayerViewType = .defaultView
    
    var showAlbumArt: Bool = true
    var showArtist: Bool = true
    var showAlbum: Bool = true
    var showCurrentChapter: Bool = true
    
    var showTrackInfo: Bool = true
    var showSequenceInfo: Bool = true
    
    var showPlayingTrackFunctions: Bool = true
    var showControls: Bool = true
    var showTimeElapsedRemaining: Bool = true
    
    var timeElapsedDisplayType: TimeElapsedDisplayType = .formatted
    var timeRemainingDisplayType: TimeRemainingDisplayType = .formatted
    
    static func deserialize(_ map: NSDictionary) -> PlayerUIState {
        
        let state = PlayerUIState()
        
        state.viewType = mapEnum(map, "viewType", PlayerViewType.defaultView)
        
        state.showAlbumArt = mapDirectly(map, "showAlbumArt", true)
        state.showArtist = mapDirectly(map, "showArtist", true)
        state.showAlbum = mapDirectly(map, "showAlbum", true)
        state.showCurrentChapter = mapDirectly(map, "showCurrentChapter", true)
        
        state.showTrackInfo = mapDirectly(map, "showTrackInfo", true)
        state.showSequenceInfo = mapDirectly(map, "showSequenceInfo", true)
        
        state.showControls = mapDirectly(map, "showControls", true)
        state.showTimeElapsedRemaining = mapDirectly(map, "showTimeElapsedRemaining", true)
        state.showPlayingTrackFunctions = mapDirectly(map, "showPlayingTrackFunctions", true)
        
        state.timeElapsedDisplayType = mapEnum(map, "timeElapsedDisplayType", TimeElapsedDisplayType.formatted)
        state.timeRemainingDisplayType = mapEnum(map, "timeRemainingDisplayType", TimeRemainingDisplayType.formatted)
        
        return state
    }
}

class WindowLayoutState: PersistentState {
    
    var showEffects: Bool = true
    var showPlaylist: Bool = true
    
    var mainWindowOrigin: NSPoint = NSPoint.zero
    var effectsWindowOrigin: NSPoint? = nil
    var playlistWindowFrame: NSRect? = nil
    
    var userLayouts: [WindowLayout] = [WindowLayout]()
    
    static func deserialize(_ map: NSDictionary) -> WindowLayoutState {
        
        let state = WindowLayoutState()
        
        state.showPlaylist = mapDirectly(map, "showPlaylist", true)
        state.showEffects = mapDirectly(map, "showEffects", true)
        
        if let mainWindowOriginDict = map["mainWindowOrigin"] as? NSDictionary, let origin = mapNSPoint(mainWindowOriginDict) {
            state.mainWindowOrigin = origin
        }
        
        if let effectsWindowOriginDict = map["effectsWindowOrigin"] as? NSDictionary, let origin = mapNSPoint(effectsWindowOriginDict) {
            state.effectsWindowOrigin = origin
        }
        
        if let frameDict = map["playlistWindowFrame"] as? NSDictionary, let originDict = frameDict["origin"] as? NSDictionary, let origin = mapNSPoint(originDict), let sizeDict = frameDict["size"] as? NSDictionary, let size = mapNSSize(sizeDict) {
            
            state.playlistWindowFrame = NSRect(origin: origin, size: size)
        }
        
        if let userLayouts = map["userLayouts"] as? [NSDictionary] {
            
            for layout in userLayouts {
                
                if let layoutName = layout["name"] as? String {
                    
                    let layoutShowEffects: Bool? = mapDirectly(layout, "showEffects")
                    let layoutShowPlaylist: Bool? = mapDirectly(layout, "showPlaylist")
                    
                    var layoutMainWindowOrigin: NSPoint?
                    var layoutEffectsWindowOrigin: NSPoint?
                    var layoutPlaylistWindowFrame: NSRect?
                    
                    if let mainWindowOriginDict = layout["mainWindowOrigin"] as? NSDictionary, let origin = mapNSPoint(mainWindowOriginDict) {
                        layoutMainWindowOrigin = origin
                    }
                    
                    if let effectsWindowOriginDict = layout["effectsWindowOrigin"] as? NSDictionary, let origin = mapNSPoint(effectsWindowOriginDict) {
                        layoutEffectsWindowOrigin = origin
                    }
                    
                    if let frameDict = layout["playlistWindowFrame"] as? NSDictionary, let originDict = frameDict["origin"] as? NSDictionary, let origin = mapNSPoint(originDict), let sizeDict = frameDict["size"] as? NSDictionary, let size = mapNSSize(sizeDict) {
                        
                        layoutPlaylistWindowFrame = NSRect(origin: origin, size: size)
                    }
                    
                    // Make sure you have all the required info
                    if layoutShowEffects != nil && layoutShowPlaylist != nil && layoutMainWindowOrigin != nil {
                        
                        if ((layoutShowEffects! && layoutEffectsWindowOrigin != nil) || !layoutShowEffects!) {
                            
                            if ((layoutShowPlaylist! && layoutPlaylistWindowFrame != nil) || !layoutShowPlaylist!) {
                                
                                let newLayout = WindowLayout(layoutName, layoutShowEffects!, layoutShowPlaylist!, layoutMainWindowOrigin!, layoutEffectsWindowOrigin, layoutPlaylistWindowFrame, false)
                                
                                state.userLayouts.append(newLayout)
                            }
                        }
                    }
                }
            }
        }
        
        return state
    }
}

extension PlayerViewState {
    
    static func initialize(_ appState: PlayerUIState) {
        
        viewType = appState.viewType
        
        showAlbumArt = appState.showAlbumArt
        showArtist = appState.showArtist
        showAlbum = appState.showAlbum
        showCurrentChapter = appState.showCurrentChapter
        
        showTrackInfo = appState.showTrackInfo
        showSequenceInfo = appState.showSequenceInfo
        
        showPlayingTrackFunctions = appState.showPlayingTrackFunctions
        showControls = appState.showControls
        showTimeElapsedRemaining = appState.showTimeElapsedRemaining
        
        timeElapsedDisplayType = appState.timeElapsedDisplayType
        timeRemainingDisplayType = appState.timeRemainingDisplayType
    }
    
    static var persistentState: PlayerUIState {
        
        let state = PlayerUIState()
        
        state.viewType = viewType
        
        state.showAlbumArt = showAlbumArt
        state.showArtist = showArtist
        state.showAlbum = showAlbum
        state.showCurrentChapter = showCurrentChapter
        
        state.showTrackInfo = showTrackInfo
        state.showSequenceInfo = showSequenceInfo
        
        state.showPlayingTrackFunctions = showPlayingTrackFunctions
        state.showControls = showControls
        state.showTimeElapsedRemaining = showTimeElapsedRemaining
        
        state.timeElapsedDisplayType = timeElapsedDisplayType
        state.timeRemainingDisplayType = timeRemainingDisplayType
        
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

extension VisualizerViewState {
    
    static func initialize(_ appState: VisualizerUIState) {
        
        if let vizTypeString = appState.type {
            type = VisualizationType(rawValue: vizTypeString) ?? .spectrogram
        } else {
            type = .spectrogram
        }
        
        options = VisualizerViewOptions()
        options.setColors(lowAmplitudeColor: appState.options?.lowAmplitudeColor?.toColor() ?? NSColor.blue,
                          highAmplitudeColor: appState.options?.highAmplitudeColor?.toColor() ?? NSColor.red)
    }
    
    static var persistentState: VisualizerUIState {
        
        let state = VisualizerUIState()
        
        state.type = type.rawValue
        state.options = VisualizerOptionsState()
        state.options?.lowAmplitudeColor = ColorState.fromColor(options.lowAmplitudeColor)
        state.options?.highAmplitudeColor = ColorState.fromColor(options.highAmplitudeColor)
        
        return state
    }
}
