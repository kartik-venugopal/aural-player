import Foundation

class MenuBarPlayerUIState: PersistentStateProtocol {
    
    var showAlbumArt: Bool = true
    var showArtist: Bool = true
    var showAlbum: Bool = true
    var showCurrentChapter: Bool = true
    
    required init?(_ map: NSDictionary) -> MenuBarPlayerUIState {
        
        let state = MenuBarPlayerUIState()
        
        state.showAlbumArt = map["showAlbumArt"] as? Bool ?? true
        state.showArtist = map["showArtist"] as? Bool ?? true
        state.showAlbum = map["showAlbum"] as? Bool ?? true
        state.showCurrentChapter = map["showCurrentChapter"] as? Bool ?? true
        
        return state
    }
}

extension MenuBarPlayerViewState {
    
    static func initialize(_ persistentState: MenuBarPlayerUIState) {
        
        showAlbumArt = persistentState.showAlbumArt
        showArtist = persistentState.showArtist
        showAlbum = persistentState.showAlbum
        showCurrentChapter = persistentState.showCurrentChapter
    }
    
    static var persistentState: MenuBarPlayerUIState {
        
        let state = MenuBarPlayerUIState()
        
        state.showAlbumArt = showAlbumArt
        state.showArtist = showArtist
        state.showAlbum = showAlbum
        state.showCurrentChapter = showCurrentChapter
        
        return state
    }
}

