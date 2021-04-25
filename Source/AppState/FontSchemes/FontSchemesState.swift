import Cocoa

/*
    Encapsulates all persistent app state for color schemes.
 */
class FontSchemesState: PersistentStateProtocol {

    var userSchemes: [FontSchemeState]?
    var systemScheme: FontSchemeState?

    init() {}

    init(_ systemScheme: FontSchemeState, _ userSchemes: [FontSchemeState]) {

        self.systemScheme = systemScheme
        self.userSchemes = userSchemes
    }

    required init?(_ map: NSDictionary) {
        
        self.userSchemes = map.arrayValue(forKey: "userSchemes", ofType: FontSchemeState.self)
        self.systemScheme = map.objectValue(forKey: "systemScheme", ofType: FontSchemeState.self)
    }
}

/*
    Encapsulates persistent app state for a single font scheme.
 */
class FontSchemeState: PersistentStateProtocol {

    let name: String
    
    let textFontName: String
    let headingFontName: String

    var player: PlayerFontSchemeState?
    var playlist: PlaylistFontSchemeState?
    var effects: EffectsFontSchemeState?

    // When saving app state to disk
    init(_ scheme: FontScheme) {

        self.name = scheme.name
        
        self.textFontName = scheme.player.infoBoxTitleFont.fontName
        self.headingFontName = scheme.playlist.tabButtonTextFont.fontName

        self.player = PlayerFontSchemeState(scheme.player)
        self.playlist = PlaylistFontSchemeState(scheme.playlist)
        self.effects = EffectsFontSchemeState(scheme.effects)
    }

    required init?(_ map: NSDictionary) {

        // Every font scheme must have a name and text/heading font names (and they must be non-empty).
        guard let name = map.nonEmptyStringValue(forKey: "name"),
              let textFontName = map.stringValue(forKey: "textFontName"),
              let headingFontName = map.stringValue(forKey: "headingFontName") else {return nil}
        
        self.name = name
        self.textFontName = textFontName
        self.headingFontName = headingFontName

        self.player = map.objectValue(forKey: "player", ofType: PlayerFontSchemeState.self)
        self.playlist = map.objectValue(forKey: "playlist", ofType: PlaylistFontSchemeState.self)
        self.effects = map.objectValue(forKey: "effects", ofType: EffectsFontSchemeState.self)
    }
}
