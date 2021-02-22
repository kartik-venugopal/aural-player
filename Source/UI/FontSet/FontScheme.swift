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
    
    init(preset: FontSchemePreset) {
        
        self.unitCaptionFont = preset.effectsUnitCaptionFont
        self.unitFunctionFont = preset.effectsUnitFunctionFont
        self.masterUnitFunctionFont = preset.effectsMasterUnitFunctionFont
        self.filterChartFont = preset.effectsFilterChartFont
    }
    
    init(_ fontScheme: EffectsFontScheme) {
        
        self.unitCaptionFont = fontScheme.unitCaptionFont
        self.unitFunctionFont = fontScheme.unitFunctionFont
        self.masterUnitFunctionFont = fontScheme.masterUnitFunctionFont
        self.filterChartFont = fontScheme.filterChartFont
    }
    
    func clone() -> EffectsFontScheme {
        return EffectsFontScheme(self)
    }
}
