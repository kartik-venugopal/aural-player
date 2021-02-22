import Cocoa

/*
    Container for fonts used by the UI
 */
class FontSet: StringKeyedItem {
    
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
    
    var player: PlayerFontSet
    var playlist: PlaylistFontSet
    var effects: EffectsFontSet
    
    init(_ name: String, _ preset: FontSetPreset) {
        
        self.name = name
        self.systemDefined = true
        
        self.player = PlayerFontSet(preset: preset)
        self.playlist = PlaylistFontSet(preset: preset)
        self.effects = EffectsFontSet(preset: preset)
    }
    
    init(_ name: String, _ systemDefined: Bool, _ fontSet: FontSet) {
        
        self.name = name
        self.systemDefined = systemDefined
        
        self.player = fontSet.player.clone()
        self.playlist  = fontSet.playlist.clone()
        self.effects = fontSet.effects.clone()
    }
    
    func clone() -> FontSet {
        return FontSet(self.name + "_clone", self.systemDefined, self)
    }
}

class PlayerFontSet {
    
    var infoBoxTitleFont: NSFont
    var infoBoxArtistAlbumFont: NSFont
    var infoBoxChapterTitleFont: NSFont
    var trackTimesFont: NSFont
    var feedbackFont: NSFont

    init(preset: FontSetPreset) {
        
        self.infoBoxTitleFont = preset.infoBoxTitleFont
        self.infoBoxArtistAlbumFont = preset.infoBoxArtistAlbumFont
        self.infoBoxChapterTitleFont = preset.infoBoxChapterTitleFont
        self.trackTimesFont = preset.trackTimesFont
        self.feedbackFont = preset.feedbackFont
    }
    
    init(_ fontSet: PlayerFontSet) {
        
        self.infoBoxTitleFont = fontSet.infoBoxTitleFont
        self.infoBoxArtistAlbumFont = fontSet.infoBoxArtistAlbumFont
        self.infoBoxChapterTitleFont = fontSet.infoBoxChapterTitleFont
        self.trackTimesFont = fontSet.trackTimesFont
        self.feedbackFont = fontSet.feedbackFont
    }
    
    func clone() -> PlayerFontSet {
        return PlayerFontSet(self)
    }
}

class PlaylistFontSet {

    var trackTextFont: NSFont
    var trackTextYOffset: CGFloat
    
    var groupTextFont: NSFont
    var groupTextYOffset: CGFloat
    
    var summaryFont: NSFont
    var tabButtonTextFont: NSFont
    var chaptersListHeaderFont: NSFont
    var chaptersListSearchFont: NSFont
    var chaptersListCaptionFont: NSFont

    init(preset: FontSetPreset) {
        
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
    
    init(_ fontSet: PlaylistFontSet) {
        
        self.trackTextFont = fontSet.trackTextFont
        self.trackTextYOffset = fontSet.trackTextYOffset
        self.groupTextFont = fontSet.groupTextFont
        self.groupTextYOffset = fontSet.groupTextYOffset
        self.summaryFont = fontSet.summaryFont
        self.tabButtonTextFont = fontSet.tabButtonTextFont
        self.chaptersListHeaderFont = fontSet.chaptersListHeaderFont
        self.chaptersListSearchFont = fontSet.chaptersListSearchFont
        self.chaptersListCaptionFont = fontSet.chaptersListCaptionFont
    }
    
    func clone() -> PlaylistFontSet {
        return PlaylistFontSet(self)
    }
}

class EffectsFontSet {

    var unitCaptionFont: NSFont
    var unitFunctionFont: NSFont
    var masterUnitFunctionFont: NSFont
    var filterChartFont: NSFont
    
    init(preset: FontSetPreset) {
        
        self.unitCaptionFont = preset.effectsUnitCaptionFont
        self.unitFunctionFont = preset.effectsUnitFunctionFont
        self.masterUnitFunctionFont = preset.effectsMasterUnitFunctionFont
        self.filterChartFont = preset.effectsFilterChartFont
    }
    
    init(_ fontSet: EffectsFontSet) {
        
        self.unitCaptionFont = fontSet.unitCaptionFont
        self.unitFunctionFont = fontSet.unitFunctionFont
        self.masterUnitFunctionFont = fontSet.masterUnitFunctionFont
        self.filterChartFont = fontSet.filterChartFont
    }
    
    func clone() -> EffectsFontSet {
        return EffectsFontSet(self)
    }
}
