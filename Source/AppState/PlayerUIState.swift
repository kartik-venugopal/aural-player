import Foundation

class PlayerUIState: PersistentStateProtocol {
    
    var viewType: PlayerViewType?
    
    var showAlbumArt: Bool?
    var showArtist: Bool?
    var showAlbum: Bool?
    var showCurrentChapter: Bool?
    
    var showTrackInfo: Bool?
    var showSequenceInfo: Bool?
    
    var showPlayingTrackFunctions: Bool?
    var showControls: Bool?
    var showTimeElapsedRemaining: Bool?
    
    var timeElapsedDisplayType: TimeElapsedDisplayType?
    var timeRemainingDisplayType: TimeRemainingDisplayType?
    
    required init?(_ map: NSDictionary) -> PlayerUIState? {
        
        let state = PlayerUIState()
        
        state.viewType = mapEnum(map, "viewType", PlayerViewType.defaultView)
        
        state.showAlbumArt = map["showAlbumArt"] as? Bool
        state.showArtist = map["showArtist"] as? Bool
        state.showAlbum = map["showAlbum"] as? Bool
        state.showCurrentChapter = map["showCurrentChapter"] as? Bool
        
        state.showTrackInfo = map["showTrackInfo"] as? Bool
        state.showSequenceInfo = map["showSequenceInfo"] as? Bool
        
        state.showControls = map["showControls"] as? Bool
        state.showTimeElapsedRemaining = map["showTimeElapsedRemaining"] as? Bool
        state.showPlayingTrackFunctions = map["showPlayingTrackFunctions"] as? Bool
        
        if let timeElapsedDisplayTypeString = map["timeElapsedDisplayType"] as? String,
           let timeElapsedDisplayType = TimeElapsedDisplayType(rawValue: timeElapsedDisplayTypeString) {
            
            state.timeElapsedDisplayType = timeElapsedDisplayType
        }
        
        if let timeRemainingDisplayTypeString = map["timeRemainingDisplayType"] as? String,
           let timeRemainingDisplayType = TimeRemainingDisplayType(rawValue: timeRemainingDisplayTypeString) {
            
            state.timeRemainingDisplayType = timeRemainingDisplayType
        }
        
        return state
    }
}

extension PlayerViewState {
    
    static func initialize(_ persistentState: PlayerUIState) {
        
        viewType = persistentState.viewType ?? PlayerViewDefaults.viewType
        
        showAlbumArt = persistentState.showAlbumArt ?? PlayerViewDefaults.showAlbumArt
        showArtist = persistentState.showArtist ?? PlayerViewDefaults.showArtist
        showAlbum = persistentState.showAlbum ?? PlayerViewDefaults.showAlbum
        showCurrentChapter = persistentState.showCurrentChapter ?? PlayerViewDefaults.showCurrentChapter
        
        showTrackInfo = persistentState.showTrackInfo ?? PlayerViewDefaults.showTrackInfo
        
        showPlayingTrackFunctions = persistentState.showPlayingTrackFunctions ?? PlayerViewDefaults.showPlayingTrackFunctions
        showControls = persistentState.showControls ?? PlayerViewDefaults.showControls
        showTimeElapsedRemaining = persistentState.showTimeElapsedRemaining ?? PlayerViewDefaults.showTimeElapsedRemaining
        
        timeElapsedDisplayType = persistentState.timeElapsedDisplayType ?? PlayerViewDefaults.timeElapsedDisplayType
        timeRemainingDisplayType = persistentState.timeRemainingDisplayType ?? PlayerViewDefaults.timeRemainingDisplayType
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
