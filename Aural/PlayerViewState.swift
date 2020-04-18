import Foundation

// Convenient accessor for information about the current playlist view
class PlayerViewState {
    
    static var viewType: PlayerViewType = .defaultView
    
    // Settings for individual track metadata fields
    
    static var showAlbumArt: Bool = true
    static var showArtist: Bool = true
    static var showAlbum: Bool = true
    static var showCurrentChapter: Bool = true
    
    static var showTrackInfo: Bool = true
    static var showSequenceInfo: Bool = false
    
    static var showPlayingTrackFunctions: Bool = true
    static var showControls: Bool = true
    static var showTimeElapsedRemaining: Bool = true
    
    static var timeElapsedDisplayType: TimeElapsedDisplayType = .formatted
    static var timeRemainingDisplayType: TimeRemainingDisplayType = .formatted
    
    static var textSize: TextSize = .normal
    
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
        
        textSize = appState.textSize
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
        
        state.textSize = textSize
        
        return state
    }
}

enum PlayerViewType: String {
    
    case defaultView
    case expandedArt
}
