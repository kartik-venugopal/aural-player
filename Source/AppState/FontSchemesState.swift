import Cocoa

/*
    Encapsulates all persistent app state for color schemes.
 */
class FontSchemesState: PersistentState {

    var userSchemes: [FontSchemeState] = []
    var systemScheme: FontSchemeState?

    init() {}

    init(_ systemScheme: FontSchemeState, _ userSchemes: [FontSchemeState]) {

        self.systemScheme = systemScheme
        self.userSchemes = userSchemes
    }

    static func deserialize(_ map: NSDictionary) -> PersistentState {

        let state = FontSchemesState()

        if let arr = map["userSchemes"] as? NSArray {

            for dict in arr {

                if let theDict = dict as? NSDictionary, let userScheme = FontSchemeState.deserialize(theDict) as? FontSchemeState {
                    state.userSchemes.append(userScheme)
                }
            }
        }

        if let dict = map["systemScheme"] as? NSDictionary, let scheme = FontSchemeState.deserialize(dict) as? FontSchemeState {
            state.systemScheme = scheme
        }

        return state
    }
}

/*
    Encapsulates persistent app state for a single color scheme.
 */
class FontSchemeState: PersistentState {

    var name: String = ""
    
    var textFontName: String = ""
    var headingFontName: String = ""

    var player: PlayerFontSchemeState?
    var playlist: PlaylistFontSchemeState?
    var effects: EffectsFontSchemeState?

    init() {}

    // When saving app state to disk
    init(_ scheme: FontScheme) {

        self.name = scheme.name
        
        self.textFontName = scheme.player.infoBoxTitleFont.fontName
        self.headingFontName = scheme.playlist.tabButtonTextFont.fontName

        self.player = PlayerFontSchemeState(scheme.player)
        self.playlist = PlaylistFontSchemeState(scheme.playlist)
        self.effects = EffectsFontSchemeState(scheme.effects)
    }

    static func deserialize(_ map: NSDictionary) -> PersistentState {

        let state = FontSchemeState()

        if let name = map["name"] as? String {
            state.name = name
        }

        state.textFontName = map["textFontName"] as? String ?? ""
        state.headingFontName = map["headingFontName"] as? String ?? ""

        if let dict = map["player"] as? NSDictionary, let playerState = PlayerFontSchemeState.deserialize(dict) as? PlayerFontSchemeState {
            state.player = playerState
        }

        if let dict = map["playlist"] as? NSDictionary, let playlistState = PlaylistFontSchemeState.deserialize(dict) as? PlaylistFontSchemeState {
            state.playlist = playlistState
        }

        if let dict = map["effects"] as? NSDictionary, let effectsState = EffectsFontSchemeState.deserialize(dict) as? EffectsFontSchemeState {
            state.effects = effectsState
        }

        return state
    }
}

/*
    Encapsulates persistent app state for a single PlayerFontScheme.
 */
class PlayerFontSchemeState: PersistentState {

    var titleSize: CGFloat = 12
    var artistAlbumSize: CGFloat = 12
    var chapterTitleSize: CGFloat = 12
    var trackTimesSize: CGFloat = 12
    var feedbackTextSize: CGFloat = 12

    init() {}

    init(_ scheme: PlayerFontScheme) {

        self.titleSize = scheme.infoBoxTitleFont.pointSize
        self.artistAlbumSize = scheme.infoBoxArtistAlbumFont.pointSize
        self.chapterTitleSize = scheme.infoBoxChapterTitleFont.pointSize
        self.trackTimesSize = scheme.trackTimesFont.pointSize
        self.feedbackTextSize = scheme.feedbackFont.pointSize
    }

    static func deserialize(_ map: NSDictionary) -> PersistentState {

        let state = PlayerFontSchemeState()

        if let titleSize = map["titleSize"] as? NSNumber {
            state.titleSize = CGFloat(titleSize.floatValue)
        }
        
        if let artistAlbumSize = map["artistAlbumSize"] as? NSNumber {
            state.artistAlbumSize = CGFloat(artistAlbumSize.floatValue)
        }
        
        if let chapterTitleSize = map["chapterTitleSize"] as? NSNumber {
            state.chapterTitleSize = CGFloat(chapterTitleSize.floatValue)
        }
        
        if let trackTimesSize = map["trackTimesSize"] as? NSNumber {
            state.trackTimesSize = CGFloat(trackTimesSize.floatValue)
        }
        
        if let feedbackTextSize = map["feedbackTextSize"] as? NSNumber {
            state.feedbackTextSize = CGFloat(feedbackTextSize.floatValue)
        }

        return state
    }
}

/*
    Encapsulates persistent app state for a single PlaylistFontScheme.
 */
class PlaylistFontSchemeState: PersistentState {

    var trackTextSize: CGFloat = 12
    var trackTextYOffset: Int = 0
    
    var groupTextSize: CGFloat = 12
    var groupTextYOffset: Int = 0
    
    var summarySize: CGFloat = 12
    var tabButtonTextSize: CGFloat = 12
    
    var chaptersListHeaderSize: CGFloat = 12
    var chaptersListSearchSize: CGFloat = 12
    var chaptersListCaptionSize: CGFloat = 12

    init() {}

    init(_ scheme: PlaylistFontScheme) {

        self.trackTextSize = scheme.trackTextFont.pointSize
        self.trackTextYOffset = roundedInt(scheme.trackTextYOffset)
        
        self.groupTextSize = scheme.groupTextFont.pointSize
        self.groupTextYOffset = roundedInt(scheme.groupTextYOffset)
        
        self.summarySize = scheme.summaryFont.pointSize
        self.tabButtonTextSize = scheme.tabButtonTextFont.pointSize
        
        self.chaptersListHeaderSize = scheme.chaptersListHeaderFont.pointSize
        self.chaptersListCaptionSize = scheme.chaptersListCaptionFont.pointSize
        self.chaptersListSearchSize = scheme.chaptersListSearchFont.pointSize
    }

    static func deserialize(_ map: NSDictionary) -> PersistentState {

        let state = PlaylistFontSchemeState()

        if let trackTextSize = map["trackTextSize"] as? NSNumber {
            state.trackTextSize = CGFloat(trackTextSize.floatValue)
        }
        
        if let trackTextYOffset = map["trackTextYOffset"] as? NSNumber {
            state.trackTextYOffset = trackTextYOffset.intValue
        }
        
        if let groupTextSize = map["groupTextSize"] as? NSNumber {
            state.groupTextSize = CGFloat(groupTextSize.floatValue)
        }
        
        if let groupTextYOffset = map["groupTextYOffset"] as? NSNumber {
            state.groupTextYOffset = groupTextYOffset.intValue
        }
        
        if let summarySize = map["summarySize"] as? NSNumber {
            state.summarySize = CGFloat(summarySize.floatValue)
        }
        
        if let tabButtonTextSize = map["tabButtonTextSize"] as? NSNumber {
            state.tabButtonTextSize = CGFloat(tabButtonTextSize.floatValue)
        }
        
        if let chaptersListHeaderSize = map["chaptersListHeaderSize"] as? NSNumber {
            state.chaptersListHeaderSize = CGFloat(chaptersListHeaderSize.floatValue)
        }
        
        if let chaptersListCaptionSize = map["chaptersListCaptionSize"] as? NSNumber {
            state.chaptersListCaptionSize = CGFloat(chaptersListCaptionSize.floatValue)
        }
        
        if let chaptersListSearchSize = map["chaptersListSearchSize"] as? NSNumber {
            state.chaptersListSearchSize = CGFloat(chaptersListSearchSize.floatValue)
        }

        return state
    }
}

/*
    Encapsulates persistent app state for a single EffectsFontScheme.
 */
class EffectsFontSchemeState: PersistentState {

    var unitCaptionSize: CGFloat = 12
    var unitFunctionSize: CGFloat = 12
    var masterUnitFunctionSize: CGFloat = 12
    var filterChartSize: CGFloat = 12

    init() {}

    init(_ scheme: EffectsFontScheme) {

        self.unitCaptionSize = scheme.unitCaptionFont.pointSize
        self.unitFunctionSize = scheme.unitFunctionFont.pointSize
        self.masterUnitFunctionSize = scheme.masterUnitFunctionFont.pointSize
        self.filterChartSize = scheme.filterChartFont.pointSize
    }

    static func deserialize(_ map: NSDictionary) -> PersistentState {

        let state = EffectsFontSchemeState()

        if let unitCaptionSize = map["unitCaptionSize"] as? NSNumber {
            state.unitCaptionSize = CGFloat(unitCaptionSize.floatValue)
        }
        
        if let unitFunctionSize = map["unitFunctionSize"] as? NSNumber {
            state.unitFunctionSize = CGFloat(unitFunctionSize.floatValue)
        }
        
        if let masterUnitFunctionSize = map["masterUnitFunctionSize"] as? NSNumber {
            state.masterUnitFunctionSize = CGFloat(masterUnitFunctionSize.floatValue)
        }
        
        if let filterChartSize = map["filterChartSize"] as? NSNumber {
            state.filterChartSize = CGFloat(filterChartSize.floatValue)
        }

        return state
    }
}
