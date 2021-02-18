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
        
        self.player = PlayerFontSet(preset: preset)
        self.playlist = PlaylistFontSet(preset: preset)
        self.effects = EffectsFontSet(preset: preset)
        
        self.systemDefined = true
    }
    
    func applyFontSet(_ fontSet: FontSet) {
        
        player.applyFontSet(fontSet.player)
        playlist.applyFontSet(fontSet.playlist)
        effects.applyFontSet(fontSet.effects)
    }
}

class PlayerFontSet {
    
    var infoBoxTitleFont_normal: NSFont
//    var infoBoxTitleFont_larger: NSFont
//    var infoBoxTitleFont_largest: NSFont
    
    var infoBoxTitleFont: NSFont {
        
//        switch PlayerViewState.textSize {
//
//        case .normal: return infoBoxTitleFont_normal
//
//        case .larger: return infoBoxTitleFont_larger
//
//        case .largest: return infoBoxTitleFont_largest
//
//        }
        return infoBoxTitleFont_normal
    }
    
    var infoBoxArtistAlbumFont_normal: NSFont
//    var infoBoxArtistAlbumFont_larger: NSFont
//    var infoBoxArtistAlbumFont_largest: NSFont
    
    var infoBoxArtistAlbumFont: NSFont {
        
//        switch PlayerViewState.textSize {
//
//        case .normal: return infoBoxArtistAlbumFont_normal
//
//        case .larger: return infoBoxArtistAlbumFont_larger
//
//        case .largest: return infoBoxArtistAlbumFont_largest
//
//        }
        return infoBoxArtistAlbumFont_normal
    }
    
    var infoBoxChapterFont_normal: NSFont
    
    var infoBoxChapterFont: NSFont {
        return infoBoxChapterFont_normal
    }
    
//    var infoBoxChapterFont_normal: NSFont
//    var infoBoxChapterFont_larger: NSFont
//    var infoBoxChapterFont_largest: NSFont
    
    var trackTimesFont_normal: NSFont
//    var trackTimesFont_larger: NSFont
//    var trackTimesFont_largest: NSFont
    
    var trackTimesFont: NSFont {
        
//        switch PlayerViewState.textSize {
//
//        case .normal: return trackTimesFont_normal
//
//        case .larger: return trackTimesFont_larger
//
//        case .largest: return trackTimesFont_largest
//
//        }
        return trackTimesFont_normal
    }
    
    var feedbackFont_normal: NSFont
    
    var feedbackFont: NSFont {
        return feedbackFont_normal
    }
    
    //    var progressArcFont: NSFont
    
//    var feedbackFont_normal: NSFont
//    var feedbackFont_larger: NSFont
//    var feedbackFont_largest: NSFont
//
//    var textButtonFont_normal: NSFont
//    var textButtonFont_larger: NSFont
//    var textButtonFont_largest: NSFont
    
    init(preset: FontSetPreset) {
        
        self.infoBoxTitleFont_normal = preset.infoBoxTitleFont_normal
        self.infoBoxArtistAlbumFont_normal = preset.infoBoxArtistAlbumFont_normal
        self.infoBoxChapterFont_normal = preset.infoBoxChapterFont_normal
        
        self.trackTimesFont_normal = preset.trackTimesFont_normal
        self.feedbackFont_normal = preset.feedbackFont_normal
    }
    
    func applyFontSet(_ fontSet: PlayerFontSet) {
        
        self.infoBoxTitleFont_normal = fontSet.infoBoxTitleFont_normal
        self.infoBoxArtistAlbumFont_normal = fontSet.infoBoxArtistAlbumFont_normal
        self.infoBoxChapterFont_normal = fontSet.infoBoxChapterFont_normal
        
        self.trackTimesFont_normal = fontSet.trackTimesFont_normal
        self.feedbackFont_normal = fontSet.feedbackFont_normal
    }
}

class PlaylistFontSet {

    var trackTextFont_normal: NSFont
//    var trackTextFont_larger: NSFont
//    var trackTextFont_largest: NSFont
    var trackTextFont: NSFont {
        return trackTextFont_normal
    }
    
    var groupTextFont_normal: NSFont
    
    var groupTextFont: NSFont {
        return groupTextFont_normal
    }
//
//    var groupTextFont_normal: NSFont
//    var groupTextFont_larger: NSFont
//    var groupTextFont_largest: NSFont
//
//    var summaryFont_normal: NSFont
//    var summaryFont_larger: NSFont
//    var summaryFont_largest: NSFont
//
//    var chaptersListHeaderFont_normal: NSFont
//    var chaptersListHeaderFont_larger: NSFont
//    var chaptersListHeaderFont_largest: NSFont
//
    var tabButtonTextFont_normal: NSFont

    var tabButtonTextFont: NSFont {
        
//        switch PlaylistViewState.textSize {
//
//        case .normal: return tabButtonTextFont_normal
//
//        case .larger: return tabButtonTextFont_larger
//
//        case .largest: return tabButtonTextFont_largest
//
//        }
        
        return tabButtonTextFont_normal
    }
    
    var summaryFont_normal: NSFont
    
    var summaryFont: NSFont {
        return summaryFont_normal
    }
    
    var chaptersListHeaderFont_normal: NSFont
     
    var chaptersListHeaderFont: NSFont {
        return chaptersListHeaderFont_normal
    }
    
    var chaptersListSearchFont_normal: NSFont
     
    var chaptersListSearchFont: NSFont {
        return chaptersListSearchFont_normal
    }
    
    var chaptersListCaptionFont_normal: NSFont
     
    var chaptersListCaptionFont: NSFont {
        return chaptersListCaptionFont_normal
    }

    init(preset: FontSetPreset) {
        
        self.trackTextFont_normal = preset.playlistTrackTextFont_normal
        self.groupTextFont_normal = preset.playlistGroupTextFont_normal
        self.tabButtonTextFont_normal = preset.playlistTabTextFont_normal
        self.summaryFont_normal = preset.playlistSummaryFont_normal
        
        self.chaptersListHeaderFont_normal = preset.chaptersListHeaderFont_normal
        self.chaptersListSearchFont_normal = preset.chaptersListSearchFont_normal
        self.chaptersListCaptionFont_normal = preset.chaptersListCaptionFont_normal
    }
    
    func applyFontSet(_ fontSet: PlaylistFontSet) {
        
        self.trackTextFont_normal = fontSet.trackTextFont_normal
        self.groupTextFont_normal = fontSet.groupTextFont_normal
        self.tabButtonTextFont_normal = fontSet.tabButtonTextFont_normal
        self.summaryFont_normal = fontSet.summaryFont_normal
        
        self.chaptersListHeaderFont_normal = fontSet.chaptersListHeaderFont_normal
        self.chaptersListSearchFont_normal = fontSet.chaptersListSearchFont_normal
        self.chaptersListCaptionFont_normal = fontSet.chaptersListCaptionFont_normal
    }
}

//    var tabsFont_larger: NSFont
//    var tabsFont_largest: NSFont
//
//    // Font used by the playlist tab view buttons
//    var tabViewButtonFont: NSFont
//    var tabViewButtonBoldFont: NSFont
//
//    var selectedTabFont_normal: NSFont
//    var selectedTabFont_larger: NSFont
//    var selectedTabFont_largest: NSFont
//
//    var chapterSearchFont_larger: NSFont
//    var chapterSearchFont_largest: NSFont
//
//    var chaptersListCaptionFont_larger: NSFont
//    var chaptersListCaptionFont_largest: NSFont
//}
//
class EffectsFontSet {

//    var tabFont_normal: NSFont
//    var tabFont_larger: NSFont
//    var tabFont_largest: NSFont
//
//    var selectedTabFont_normal: NSFont
//    var selectedTabFont_larger: NSFont
//    var selectedTabFont_largest: NSFont
//
    var unitCaptionFont_normal: NSFont
    //    var unitCaptionFont_larger: NSFont
    //    var unitCaptionFont_largest: NSFont
    
    var unitCaptionFont: NSFont {
        return unitCaptionFont_normal
    }
    
    var unitFunctionFont_normal: NSFont
    
    var unitFunctionFont: NSFont {
        return unitFunctionFont_normal
    }

    var masterUnitFunctionFont_normal: NSFont
//    var masterUnitFunctionFont_larger: NSFont
//    var masterUnitFunctionFont_largest: NSFont
    
    var masterUnitFunctionFont: NSFont {
        return masterUnitFunctionFont_normal
    }
    
    var filterChartFont_normal: NSFont
    
    var filterChartFont: NSFont {
        return filterChartFont_normal
    }
    
    init(preset: FontSetPreset) {
        
        self.unitCaptionFont_normal = preset.effectsUnitCaptionFont_normal
        self.unitFunctionFont_normal = preset.effectsUnitFunctionFont_normal
        self.masterUnitFunctionFont_normal = preset.effectsMasterUnitFunctionFont_normal
        self.filterChartFont_normal = preset.effectsFilterChartFont_normal
    }
    
    func applyFontSet(_ fontSet: EffectsFontSet) {
        
        self.unitCaptionFont_normal = fontSet.unitCaptionFont_normal
        self.unitFunctionFont_normal = fontSet.unitFunctionFont_normal
        self.masterUnitFunctionFont_normal = fontSet.masterUnitFunctionFont_normal
        self.filterChartFont_normal = fontSet.filterChartFont_normal
    }

//    var unitFunctionFont_normal: NSFont
//    var unitFunctionFont_larger: NSFont
//    var unitFunctionFont_largest: NSFont
//
//    var unitFunctionBoldFont_normal: NSFont
//    var unitFunctionBoldFont_larger: NSFont
//    var unitFunctionBoldFont_largest: NSFont
//
//    var filterChartFont_normal: NSFont
//    var filterChartFont_larger: NSFont
//    var filterChartFont_largest: NSFont
}
