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
    
    init() {}
    
    required init?(_ map: NSDictionary) {
        
        self.viewType = map.enumValue(forKey: "viewType", ofType: PlayerViewType.self)
        
        self.showAlbumArt = map.boolValue(forKey: "showAlbumArt")
        self.showArtist = map.boolValue(forKey: "showArtist")
        self.showAlbum = map.boolValue(forKey: "showAlbum")
        self.showCurrentChapter = map.boolValue(forKey: "showCurrentChapter")
        
        self.showTrackInfo = map.boolValue(forKey: "showTrackInfo")
        self.showSequenceInfo = map.boolValue(forKey: "showSequenceInfo")
        
        self.showControls = map.boolValue(forKey: "showControls")
        self.showTimeElapsedRemaining = map.boolValue(forKey: "showTimeElapsedRemaining")
        self.showPlayingTrackFunctions = map.boolValue(forKey: "showPlayingTrackFunctions")
        
        self.timeElapsedDisplayType = map.enumValue(forKey: "timeElapsedDisplayType", ofType: TimeElapsedDisplayType.self)
        self.timeRemainingDisplayType = map.enumValue(forKey: "timeRemainingDisplayType", ofType: TimeRemainingDisplayType.self)
    }
}

extension PlayerViewState {
    
    static func initialize(_ persistentState: PlayerUIState?) {
        
        viewType = persistentState?.viewType ?? PlayerViewDefaults.viewType
        
        showAlbumArt = persistentState?.showAlbumArt ?? PlayerViewDefaults.showAlbumArt
        showArtist = persistentState?.showArtist ?? PlayerViewDefaults.showArtist
        showAlbum = persistentState?.showAlbum ?? PlayerViewDefaults.showAlbum
        showCurrentChapter = persistentState?.showCurrentChapter ?? PlayerViewDefaults.showCurrentChapter
        
        showTrackInfo = persistentState?.showTrackInfo ?? PlayerViewDefaults.showTrackInfo
        
        showPlayingTrackFunctions = persistentState?.showPlayingTrackFunctions ?? PlayerViewDefaults.showPlayingTrackFunctions
        showControls = persistentState?.showControls ?? PlayerViewDefaults.showControls
        showTimeElapsedRemaining = persistentState?.showTimeElapsedRemaining ?? PlayerViewDefaults.showTimeElapsedRemaining
        
        timeElapsedDisplayType = persistentState?.timeElapsedDisplayType ?? PlayerViewDefaults.timeElapsedDisplayType
        timeRemainingDisplayType = persistentState?.timeRemainingDisplayType ?? PlayerViewDefaults.timeRemainingDisplayType
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
