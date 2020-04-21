import Foundation

/*
 Encapsulates UI state
 */
class UIState: PersistentState {
    
    var windowLayout: WindowLayoutState = WindowLayoutState()
    var colorSchemes: ColorSchemesState = ColorSchemesState()
    var player: PlayerUIState = PlayerUIState()
    var playlist: PlaylistUIState = PlaylistUIState()
    var effects: EffectsUIState = EffectsUIState()
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = UIState()
        
        if let windowLayoutMap = map["windowLayout"] as? NSDictionary {
            state.windowLayout = WindowLayoutState.deserialize(windowLayoutMap) as! WindowLayoutState
        }
        
        if let playerMap = map["player"] as? NSDictionary {
            state.player = PlayerUIState.deserialize(playerMap) as! PlayerUIState
        }
        
        if let effectsMap = map["effects"] as? NSDictionary {
            state.effects = EffectsUIState.deserialize(effectsMap) as! EffectsUIState
        }
        
        if let playlistMap = map["playlist"] as? NSDictionary {
            state.playlist = PlaylistUIState.deserialize(playlistMap) as! PlaylistUIState
        }
        
        return state
    }
}

class PlaylistUIState: PersistentState {
    
    var textSize: TextSize = .normal
    var view: String = "Tracks"
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = PlaylistUIState()
        state.textSize = mapEnum(map, "textSize", TextSize.normal)
        
        if let viewName = map["view"] as? String {
            state.view = viewName
        }
        
        return state
    }
}

class EffectsUIState: PersistentState {
    
    var textSize: TextSize = .normal
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = EffectsUIState()
        state.textSize = mapEnum(map, "textSize", TextSize.normal)
        
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
    
    var textSize: TextSize = .normal
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
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
        
        state.textSize = mapEnum(map, "textSize", TextSize.normal)
        
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
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
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
