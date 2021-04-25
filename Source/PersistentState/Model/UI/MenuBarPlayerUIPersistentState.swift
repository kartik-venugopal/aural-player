import Foundation

class MenuBarPlayerUIPersistentState: PersistentStateProtocol {
    
    var showAlbumArt: Bool?
    var showArtist: Bool?
    var showAlbum: Bool?
    var showCurrentChapter: Bool?
    
    init() {}
    
    required init?(_ map: NSDictionary) {
        
        self.showAlbumArt = map.boolValue(forKey: "showAlbumArt")
        self.showArtist = map.boolValue(forKey: "showArtist")
        self.showAlbum = map.boolValue(forKey: "showAlbum")
        self.showCurrentChapter = map.boolValue(forKey: "showCurrentChapter")
    }
}

extension MenuBarPlayerViewState {
    
    static func initialize(_ persistentState: MenuBarPlayerUIPersistentState?) {
        
        showAlbumArt = persistentState?.showAlbumArt ?? MenuBarPlayerViewStateDefaults.showAlbumArt
        showArtist = persistentState?.showArtist ?? MenuBarPlayerViewStateDefaults.showArtist
        showAlbum = persistentState?.showAlbum ?? MenuBarPlayerViewStateDefaults.showAlbum
        showCurrentChapter = persistentState?.showCurrentChapter ?? MenuBarPlayerViewStateDefaults.showCurrentChapter
    }
    
    static var persistentState: MenuBarPlayerUIPersistentState {
        
        let state = MenuBarPlayerUIPersistentState()
        
        state.showAlbumArt = showAlbumArt
        state.showArtist = showArtist
        state.showAlbum = showAlbum
        state.showCurrentChapter = showCurrentChapter
        
        return state
    }
}

