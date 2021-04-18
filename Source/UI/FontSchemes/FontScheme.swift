import Cocoa

/*
    Container for fonts used by the UI
 */
class FontScheme: StringKeyedItem {
    
    // Displayed name
    var name: String
    
    var key: String {
        
        get {
            return name
        }
        
        set(newValue) {
            name = newValue
        }
    }

    // False if defined by the user
    let systemDefined: Bool
    
    var player: PlayerFontScheme
    var playlist: PlaylistFontScheme
    var effects: EffectsFontScheme
    
    // Used when loading app state on startup
    init(_ persistentState: FontSchemeState?, _ systemDefined: Bool) {
        
        self.name = persistentState?.name ?? ""
        self.systemDefined = systemDefined
        
        self.player = PlayerFontScheme(persistentState)
        self.playlist = PlaylistFontScheme(persistentState)
        self.effects = EffectsFontScheme(persistentState)
    }
    
    init(_ name: String, _ preset: FontSchemePreset) {
        
        self.name = name
        self.systemDefined = true
        
        self.player = PlayerFontScheme(preset: preset)
        self.playlist = PlaylistFontScheme(preset: preset)
        self.effects = EffectsFontScheme(preset: preset)
    }
    
    init(_ name: String, _ systemDefined: Bool, _ fontScheme: FontScheme) {
        
        self.name = name
        self.systemDefined = systemDefined
        
        self.player = fontScheme.player.clone()
        self.playlist  = fontScheme.playlist.clone()
        self.effects = fontScheme.effects.clone()
    }
    
    func clone() -> FontScheme {
        return FontScheme(self.name + "_clone", self.systemDefined, self)
    }
}

class PlayerFontScheme {
    
    var infoBoxTitleFont: NSFont
    var infoBoxArtistAlbumFont: NSFont
    var infoBoxChapterTitleFont: NSFont
    var trackTimesFont: NSFont
    var feedbackFont: NSFont
    
    init(_ persistentState: FontSchemeState?) {
        
        self.infoBoxTitleFont = FontSchemePreset.standard.infoBoxTitleFont
        self.infoBoxArtistAlbumFont = FontSchemePreset.standard.infoBoxArtistAlbumFont
        self.infoBoxChapterTitleFont = FontSchemePreset.standard.infoBoxChapterTitleFont
        self.trackTimesFont = FontSchemePreset.standard.trackTimesFont
        self.feedbackFont = FontSchemePreset.standard.feedbackFont
        
        guard let textFontName = persistentState?.textFontName else {
            return
        }
        
        if let titleSize = persistentState?.player?.titleSize, let titleFont = NSFont(name: textFontName, size: titleSize) {
            self.infoBoxTitleFont = titleFont
        }
        
        if let artistAlbumSize = persistentState?.player?.artistAlbumSize, let artistAlbumFont = NSFont(name: textFontName, size: artistAlbumSize) {
            self.infoBoxArtistAlbumFont = artistAlbumFont
        }
        
        if let chapterTitleSize = persistentState?.player?.chapterTitleSize, let chapterTitleFont = NSFont(name: textFontName, size: chapterTitleSize) {
            self.infoBoxChapterTitleFont = chapterTitleFont
        }
        
        if let trackTimesSize = persistentState?.player?.trackTimesSize, let trackTimesFont = NSFont(name: textFontName, size: trackTimesSize) {
            self.trackTimesFont = trackTimesFont
        }
        
        if let feedbackTextSize = persistentState?.player?.feedbackTextSize, let feedbackFont = NSFont(name: textFontName, size: feedbackTextSize) {
            self.feedbackFont = feedbackFont
        }
    }

    init(preset: FontSchemePreset) {
        
        self.infoBoxTitleFont = preset.infoBoxTitleFont
        self.infoBoxArtistAlbumFont = preset.infoBoxArtistAlbumFont
        self.infoBoxChapterTitleFont = preset.infoBoxChapterTitleFont
        self.trackTimesFont = preset.trackTimesFont
        self.feedbackFont = preset.feedbackFont
    }
    
    init(_ fontScheme: PlayerFontScheme) {
        
        self.infoBoxTitleFont = fontScheme.infoBoxTitleFont
        self.infoBoxArtistAlbumFont = fontScheme.infoBoxArtistAlbumFont
        self.infoBoxChapterTitleFont = fontScheme.infoBoxChapterTitleFont
        self.trackTimesFont = fontScheme.trackTimesFont
        self.feedbackFont = fontScheme.feedbackFont
    }
    
    func clone() -> PlayerFontScheme {
        return PlayerFontScheme(self)
    }
}

class PlaylistFontScheme {

    var trackTextFont: NSFont
    var trackTextYOffset: CGFloat
    
    var groupTextFont: NSFont
    var groupTextYOffset: CGFloat
    
    var summaryFont: NSFont
    var tabButtonTextFont: NSFont
    var chaptersListHeaderFont: NSFont
    var chaptersListSearchFont: NSFont
    var chaptersListCaptionFont: NSFont
    
    init(_ persistentState: FontSchemeState?) {
        
        self.trackTextFont = FontSchemePreset.standard.playlistTrackTextFont
        self.trackTextYOffset = FontSchemePreset.standard.playlistTrackTextYOffset
        
        self.groupTextFont = FontSchemePreset.standard.playlistGroupTextFont
        self.groupTextYOffset = FontSchemePreset.standard.playlistGroupTextYOffset
        
        self.summaryFont = FontSchemePreset.standard.playlistSummaryFont
        self.tabButtonTextFont = FontSchemePreset.standard.playlistTabButtonTextFont
        
        self.chaptersListHeaderFont = FontSchemePreset.standard.chaptersListHeaderFont
        self.chaptersListCaptionFont = FontSchemePreset.standard.chaptersListCaptionFont
        self.chaptersListSearchFont = FontSchemePreset.standard.chaptersListSearchFont
        
        guard let textFontName = persistentState?.textFontName, let headingFontName = persistentState?.headingFontName else {
            return
        }
        
        if let trackTextSize = persistentState?.playlist?.trackTextSize, let trackTextFont = NSFont(name: textFontName, size: trackTextSize) {
            self.trackTextFont = trackTextFont
        }
        
        if let trackTextYOffset = persistentState?.playlist?.trackTextYOffset {
            self.trackTextYOffset = CGFloat(trackTextYOffset)
        }
        
        if let groupTextSize = persistentState?.playlist?.groupTextSize, let groupTextFont = NSFont(name: textFontName, size: groupTextSize) {
            self.groupTextFont = groupTextFont
        }
        
        if let groupTextYOffset = persistentState?.playlist?.groupTextYOffset {
            self.groupTextYOffset = CGFloat(groupTextYOffset)
        }
        
        if let summarySize = persistentState?.playlist?.summarySize, let summaryFont = NSFont(name: textFontName, size: summarySize) {
            self.summaryFont = summaryFont
        }
        
        if let tabButtonTextSize = persistentState?.playlist?.tabButtonTextSize, let tabButtonTextFont = NSFont(name: headingFontName, size: tabButtonTextSize) {
            self.tabButtonTextFont = tabButtonTextFont
        }
        
        if let chaptersListHeaderSize = persistentState?.playlist?.chaptersListHeaderSize,
           let chaptersListHeaderFont = NSFont(name: headingFontName, size: chaptersListHeaderSize) {
            
            self.chaptersListHeaderFont = chaptersListHeaderFont
        }
        
        if let chaptersListCaptionSize = persistentState?.playlist?.chaptersListCaptionSize,
           let chaptersListCaptionFont = NSFont(name: headingFontName, size: chaptersListCaptionSize) {
            
            self.chaptersListCaptionFont = chaptersListCaptionFont
        }
        
        if let chaptersListSearchSize = persistentState?.playlist?.chaptersListSearchSize,
           let chaptersListSearchFont = NSFont(name: textFontName, size: chaptersListSearchSize) {
            
            self.chaptersListSearchFont = chaptersListSearchFont
        }
    }

    init(preset: FontSchemePreset) {
        
        self.trackTextFont = preset.playlistTrackTextFont
        self.trackTextYOffset = preset.playlistTrackTextYOffset
        self.groupTextFont = preset.playlistGroupTextFont
        self.groupTextYOffset = preset.playlistGroupTextYOffset
        self.summaryFont = preset.playlistSummaryFont
        self.tabButtonTextFont = preset.playlistTabButtonTextFont
        self.chaptersListHeaderFont = preset.chaptersListHeaderFont
        self.chaptersListSearchFont = preset.chaptersListSearchFont
        self.chaptersListCaptionFont = preset.chaptersListCaptionFont
    }
    
    init(_ fontScheme: PlaylistFontScheme) {
        
        self.trackTextFont = fontScheme.trackTextFont
        self.trackTextYOffset = fontScheme.trackTextYOffset
        self.groupTextFont = fontScheme.groupTextFont
        self.groupTextYOffset = fontScheme.groupTextYOffset
        self.summaryFont = fontScheme.summaryFont
        self.tabButtonTextFont = fontScheme.tabButtonTextFont
        self.chaptersListHeaderFont = fontScheme.chaptersListHeaderFont
        self.chaptersListSearchFont = fontScheme.chaptersListSearchFont
        self.chaptersListCaptionFont = fontScheme.chaptersListCaptionFont
    }
    
    func clone() -> PlaylistFontScheme {
        return PlaylistFontScheme(self)
    }
}

class EffectsFontScheme {

    var unitCaptionFont: NSFont
    var unitFunctionFont: NSFont
    var masterUnitFunctionFont: NSFont
    var filterChartFont: NSFont
    var auRowTextYOffset: CGFloat
    
    init(_ persistentState: FontSchemeState?) {
        
        self.unitCaptionFont = FontSchemePreset.standard.effectsUnitCaptionFont
        self.unitFunctionFont = FontSchemePreset.standard.effectsUnitFunctionFont
        self.masterUnitFunctionFont = FontSchemePreset.standard.effectsMasterUnitFunctionFont
        self.filterChartFont = FontSchemePreset.standard.effectsFilterChartFont
        self.auRowTextYOffset = FontSchemePreset.standard.effectsAURowTextYOffset
        
        guard let textFontName = persistentState?.textFontName, let headingFontName = persistentState?.headingFontName else {
            return
        }
        
        if let unitCaptionSize = persistentState?.effects?.unitCaptionSize, let unitCaptionFont = NSFont(name: headingFontName, size: unitCaptionSize) {
            self.unitCaptionFont = unitCaptionFont
        }
        
        if let unitFunctionSize = persistentState?.effects?.unitFunctionSize, let unitFunctionFont = NSFont(name: textFontName, size: unitFunctionSize) {
            self.unitFunctionFont = unitFunctionFont
        }
        
        if let masterUnitFunctionSize = persistentState?.effects?.masterUnitFunctionSize,
           let masterUnitFunctionFont = NSFont(name: headingFontName, size: masterUnitFunctionSize) {
            
            self.masterUnitFunctionFont = masterUnitFunctionFont
        }
        
        if let filterChartSize = persistentState?.effects?.filterChartSize, let filterChartFont = NSFont(name: textFontName, size: filterChartSize) {
            self.filterChartFont = filterChartFont
        }
        
        if let auRowTextYOffset = persistentState?.effects?.auRowTextYOffset {
            self.auRowTextYOffset = auRowTextYOffset
        }
    }
    
    init(preset: FontSchemePreset) {
        
        self.unitCaptionFont = preset.effectsUnitCaptionFont
        self.unitFunctionFont = preset.effectsUnitFunctionFont
        self.masterUnitFunctionFont = preset.effectsMasterUnitFunctionFont
        self.filterChartFont = preset.effectsFilterChartFont
        self.auRowTextYOffset = preset.effectsAURowTextYOffset
    }
    
    init(_ fontScheme: EffectsFontScheme) {
        
        self.unitCaptionFont = fontScheme.unitCaptionFont
        self.unitFunctionFont = fontScheme.unitFunctionFont
        self.masterUnitFunctionFont = fontScheme.masterUnitFunctionFont
        self.filterChartFont = fontScheme.filterChartFont
        self.auRowTextYOffset = fontScheme.auRowTextYOffset
    }
    
    func clone() -> EffectsFontScheme {
        return EffectsFontScheme(self)
    }
}
