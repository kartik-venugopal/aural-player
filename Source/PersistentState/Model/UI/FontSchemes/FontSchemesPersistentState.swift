import Cocoa

/*
    Encapsulates all persistent app state for color schemes.
 */
class FontSchemesPersistentState: PersistentStateProtocol {

    var userSchemes: [FontSchemePersistentState]?
    var systemScheme: FontSchemePersistentState?

    init() {}

    init(_ systemScheme: FontSchemePersistentState, _ userSchemes: [FontSchemePersistentState]) {

        self.systemScheme = systemScheme
        self.userSchemes = userSchemes
    }

    required init?(_ map: NSDictionary) {
        
        self.userSchemes = map.arrayValue(forKey: "userSchemes", ofType: FontSchemePersistentState.self)
        self.systemScheme = map.objectValue(forKey: "systemScheme", ofType: FontSchemePersistentState.self)
    }
}

/*
    Encapsulates persistent app state for a single font scheme.
 */
class FontSchemePersistentState: PersistentStateProtocol {

    let name: String
    
    let textFontName: String
    let headingFontName: String

    var player: PlayerFontSchemePersistentState?
    var playlist: PlaylistFontSchemePersistentState?
    var effects: EffectsFontSchemePersistentState?

    // When saving app state to disk
    init(_ scheme: FontScheme) {

        self.name = scheme.name
        
        self.textFontName = scheme.player.infoBoxTitleFont.fontName
        self.headingFontName = scheme.playlist.tabButtonTextFont.fontName

        self.player = PlayerFontSchemePersistentState(scheme.player)
        self.playlist = PlaylistFontSchemePersistentState(scheme.playlist)
        self.effects = EffectsFontSchemePersistentState(scheme.effects)
    }

    required init?(_ map: NSDictionary) {

        // Every font scheme must have a name and text/heading font names (and they must be non-empty).
        guard let name = map.nonEmptyStringValue(forKey: "name"),
              let textFontName = map.stringValue(forKey: "textFontName"),
              let headingFontName = map.stringValue(forKey: "headingFontName") else {return nil}
        
        self.name = name
        self.textFontName = textFontName
        self.headingFontName = headingFontName

        self.player = map.objectValue(forKey: "player", ofType: PlayerFontSchemePersistentState.self)
        self.playlist = map.objectValue(forKey: "playlist", ofType: PlaylistFontSchemePersistentState.self)
        self.effects = map.objectValue(forKey: "effects", ofType: EffectsFontSchemePersistentState.self)
    }
}
