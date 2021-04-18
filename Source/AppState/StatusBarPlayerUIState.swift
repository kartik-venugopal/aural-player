import Foundation

class StatusBarPlayerUIState: PersistentStateProtocol {
    
    var showAlbumArt: Bool = true
    var showArtist: Bool = true
    var showAlbum: Bool = true
    var showCurrentChapter: Bool = true
    
    static func deserialize(_ map: NSDictionary) -> StatusBarPlayerUIState {
        
        let state = StatusBarPlayerUIState()
        
        state.showAlbumArt = map["showAlbumArt"] as? Bool ?? true
        state.showArtist = map["showArtist"] as? Bool ?? true
        state.showAlbum = map["showAlbum"] as? Bool ?? true
        state.showCurrentChapter = map["showCurrentChapter"] as? Bool ?? true
        
        return state
    }
}

extension StatusBarPlayerViewState {
    
    static func initialize(_ persistentState: StatusBarPlayerUIState) {
        
        showAlbumArt = persistentState.showAlbumArt
        showArtist = persistentState.showArtist
        showAlbum = persistentState.showAlbum
        showCurrentChapter = persistentState.showCurrentChapter
    }
    
    static var persistentState: StatusBarPlayerUIState {
        
        let state = StatusBarPlayerUIState()
        
        state.showAlbumArt = showAlbumArt
        state.showArtist = showArtist
        state.showAlbum = showAlbum
        state.showCurrentChapter = showCurrentChapter
        
        return state
    }
}

