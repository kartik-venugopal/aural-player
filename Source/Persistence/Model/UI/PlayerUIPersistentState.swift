import Foundation

class PlayerUIPersistentState: PersistentStateProtocol {
    
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
        
        self.showAlbumArt = map["showAlbumArt", Bool.self]
        self.showArtist = map["showArtist", Bool.self]
        self.showAlbum = map["showAlbum", Bool.self]
        self.showCurrentChapter = map["showCurrentChapter", Bool.self]
        
        self.showTrackInfo = map["showTrackInfo", Bool.self]
        self.showSequenceInfo = map["showSequenceInfo", Bool.self]
        
        self.showControls = map["showControls", Bool.self]
        self.showTimeElapsedRemaining = map["showTimeElapsedRemaining", Bool.self]
        self.showPlayingTrackFunctions = map["showPlayingTrackFunctions", Bool.self]
        
        self.timeElapsedDisplayType = map.enumValue(forKey: "timeElapsedDisplayType", ofType: TimeElapsedDisplayType.self)
        self.timeRemainingDisplayType = map.enumValue(forKey: "timeRemainingDisplayType", ofType: TimeRemainingDisplayType.self)
    }
}

extension PlayerViewState {
    
    static func initialize(_ persistentState: PlayerUIPersistentState?) {
        
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
    
    static var persistentState: PlayerUIPersistentState {
        
        let state = PlayerUIPersistentState()
        
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
