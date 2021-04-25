import Cocoa

/*
    Encapsulates all persistent app state for color schemes.
 */
class ColorSchemesState: PersistentStateProtocol {

    let userSchemes: [ColorSchemeState]?
    let systemScheme: ColorSchemeState?
    
    init(_ systemScheme: ColorSchemeState, _ userSchemes: [ColorSchemeState]) {
        
        self.systemScheme = systemScheme
        self.userSchemes = userSchemes
    }
    
    required init?(_ map: NSDictionary) {
        
        self.userSchemes = map.arrayValue(forKey: "userSchemes", ofType: ColorSchemeState.self)
        self.systemScheme = map.objectValue(forKey: "systemScheme", ofType: ColorSchemeState.self)
    }
}

/*
    Encapsulates persistent app state for a single color scheme.
 */
class ColorSchemeState: PersistentStateProtocol {
    
    let name: String
    
    let general: GeneralColorSchemeState?
    let player: PlayerColorSchemeState?
    let playlist: PlaylistColorSchemeState?
    let effects: EffectsColorSchemeState?
    
    // When saving app state to disk
    init(_ scheme: ColorScheme) {
        
        self.name = scheme.name
        
        self.general = GeneralColorSchemeState(scheme.general)
        self.player = PlayerColorSchemeState(scheme.player)
        self.playlist = PlaylistColorSchemeState(scheme.playlist)
        self.effects = EffectsColorSchemeState(scheme.effects)
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let name = map.nonEmptyStringValue(forKey: "name") else {return nil}
        self.name = name
        
        self.general = map.objectValue(forKey: "general", ofType: GeneralColorSchemeState.self)
        self.player = map.objectValue(forKey: "player", ofType: PlayerColorSchemeState.self)
        self.playlist = map.objectValue(forKey: "playlist", ofType: PlaylistColorSchemeState.self)
        self.effects = map.objectValue(forKey: "effects", ofType: EffectsColorSchemeState.self)
    }
}
