import Foundation

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

extension PlayerViewState {
    
    static func initialize(_ appState: PlayerUIState) {
        
        viewType = appState.viewType
        
        showAlbumArt = appState.showAlbumArt
        showArtist = appState.showArtist
        showAlbum = appState.showAlbum
        showCurrentChapter = appState.showCurrentChapter
        
        showTrackInfo = appState.showTrackInfo
        
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
        
        state.showPlayingTrackFunctions = showPlayingTrackFunctions
        state.showControls = showControls
        state.showTimeElapsedRemaining = showTimeElapsedRemaining
        
        state.timeElapsedDisplayType = timeElapsedDisplayType
        state.timeRemainingDisplayType = timeRemainingDisplayType
        
        return state
    }
}
