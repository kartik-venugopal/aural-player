import Cocoa

/*
    Encapsulates all persistent app state for color schemes.
 */
class FontSchemesState: PersistentStateProtocol {

    var userSchemes: [FontSchemeState] = []
    var systemScheme: FontSchemeState?

    init() {}

    init(_ systemScheme: FontSchemeState, _ userSchemes: [FontSchemeState]) {

        self.systemScheme = systemScheme
        self.userSchemes = userSchemes
    }

    required init?(_ map: NSDictionary) -> FontSchemesState? {

        let state = FontSchemesState()

        if let arr = map["userSchemes"] as? [NSDictionary] {
            state.userSchemes = arr.compactMap {FontSchemeState.deserialize($0)}
        }

        if let dict = map["systemScheme"] as? NSDictionary {
            state.systemScheme = FontSchemeState.deserialize(dict)
        }

        return state
    }
}

/*
    Encapsulates persistent app state for a single font scheme.
 */
class FontSchemeState: PersistentStateProtocol {

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

    required init?(_ map: NSDictionary) -> FontSchemeState? {

        let state = FontSchemeState()

        // Every font scheme must have a name and text/heading font names (and they must be non-empty).
        guard let name = map["name"] as? String, !name.isEmptyAfterTrimming,
              let textFontName = map["textFontName"] as? String,
              let headingFontName = map["headingFontName"] as? String else {return nil}
        
        state.name = name
        state.textFontName = textFontName
        state.headingFontName = headingFontName

        if let dict = map["player"] as? NSDictionary {
            state.player = PlayerFontSchemeState.deserialize(dict)
        }

        if let dict = map["playlist"] as? NSDictionary {
            state.playlist = PlaylistFontSchemeState.deserialize(dict)
        }

        if let dict = map["effects"] as? NSDictionary {
            state.effects = EffectsFontSchemeState.deserialize(dict)
        }

        return state
    }
}

/*
    Encapsulates persistent app state for a single PlayerFontScheme.
 */
class PlayerFontSchemeState: PersistentStateProtocol {

    var titleSize: CGFloat?
    var artistAlbumSize: CGFloat?
    var chapterTitleSize: CGFloat?
    var trackTimesSize: CGFloat?
    var feedbackTextSize: CGFloat?

    init() {}

    init(_ scheme: PlayerFontScheme) {

        self.titleSize = scheme.infoBoxTitleFont.pointSize
        self.artistAlbumSize = scheme.infoBoxArtistAlbumFont.pointSize
        self.chapterTitleSize = scheme.infoBoxChapterTitleFont.pointSize
        self.trackTimesSize = scheme.trackTimesFont.pointSize
        self.feedbackTextSize = scheme.feedbackFont.pointSize
    }

    required init?(_ map: NSDictionary) -> PlayerFontSchemeState? {

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
class PlaylistFontSchemeState: PersistentStateProtocol {

    var trackTextSize: CGFloat?
    var trackTextYOffset: Int?
    
    var groupTextSize: CGFloat?
    var groupTextYOffset: Int?
    
    var summarySize: CGFloat?
    var tabButtonTextSize: CGFloat?
    
    var chaptersListHeaderSize: CGFloat?
    var chaptersListSearchSize: CGFloat?
    var chaptersListCaptionSize: CGFloat?

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

    required init?(_ map: NSDictionary) -> PlaylistFontSchemeState? {

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
class EffectsFontSchemeState: PersistentStateProtocol {

    var unitCaptionSize: CGFloat?
    var unitFunctionSize: CGFloat?
    var masterUnitFunctionSize: CGFloat?
    var filterChartSize: CGFloat?
    var auRowTextYOffset: CGFloat?

    init() {}

    init(_ scheme: EffectsFontScheme) {

        self.unitCaptionSize = scheme.unitCaptionFont.pointSize
        self.unitFunctionSize = scheme.unitFunctionFont.pointSize
        self.masterUnitFunctionSize = scheme.masterUnitFunctionFont.pointSize
        self.filterChartSize = scheme.filterChartFont.pointSize
        self.auRowTextYOffset = scheme.auRowTextYOffset
    }

    required init?(_ map: NSDictionary) -> EffectsFontSchemeState? {

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
        
        if let auRowTextYOffset = map["auRowTextYOffset"] as? NSNumber {
            state.auRowTextYOffset = CGFloat(auRowTextYOffset.floatValue)
        }

        return state
    }
}
