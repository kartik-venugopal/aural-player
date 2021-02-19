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
    var infoBoxTitleFont_larger: NSFont
    var infoBoxTitleFont_largest: NSFont
    
    var infoBoxTitleFont: NSFont {
        
        switch PlayerViewState.textSize {

        case .normal: return infoBoxTitleFont_normal

        case .larger: return infoBoxTitleFont_larger

        case .largest: return infoBoxTitleFont_largest

        }
    }
    
    var infoBoxArtistAlbumFont_normal: NSFont
    var infoBoxArtistAlbumFont_larger: NSFont
    var infoBoxArtistAlbumFont_largest: NSFont
    
    var infoBoxArtistAlbumFont: NSFont {
        
        switch PlayerViewState.textSize {

        case .normal: return infoBoxArtistAlbumFont_normal

        case .larger: return infoBoxArtistAlbumFont_larger

        case .largest: return infoBoxArtistAlbumFont_largest

        }
    }
    
    var infoBoxChapterFont_normal: NSFont
    var infoBoxChapterFont_larger: NSFont
    var infoBoxChapterFont_largest: NSFont
    
    var infoBoxChapterFont: NSFont {
        
        switch PlayerViewState.textSize {

        case .normal: return infoBoxChapterFont_normal

        case .larger: return infoBoxChapterFont_larger

        case .largest: return infoBoxChapterFont_largest

        }
    }
    
    var trackTimesFont_normal: NSFont
    var trackTimesFont_larger: NSFont
    var trackTimesFont_largest: NSFont
    
    var trackTimesFont: NSFont {
        
        switch PlayerViewState.textSize {

        case .normal: return trackTimesFont_normal

        case .larger: return trackTimesFont_larger

        case .largest: return trackTimesFont_largest

        }
    }
    
    var feedbackFont_normal: NSFont
    var feedbackFont_larger: NSFont
    var feedbackFont_largest: NSFont
    
    var feedbackFont: NSFont {
        
        switch PlayerViewState.textSize {

        case .normal: return feedbackFont_normal

        case .larger: return feedbackFont_larger

        case .largest: return feedbackFont_largest

        }
    }
    
    init(preset: FontSetPreset) {
        
        self.infoBoxTitleFont_normal = preset.infoBoxTitleFont_normal
        self.infoBoxTitleFont_larger = preset.infoBoxTitleFont_larger
        self.infoBoxTitleFont_largest = preset.infoBoxTitleFont_largest
        
        self.infoBoxArtistAlbumFont_normal = preset.infoBoxArtistAlbumFont_normal
        self.infoBoxArtistAlbumFont_larger = preset.infoBoxArtistAlbumFont_larger
        self.infoBoxArtistAlbumFont_largest = preset.infoBoxArtistAlbumFont_largest
        
        self.infoBoxChapterFont_normal = preset.infoBoxChapterFont_normal
        self.infoBoxChapterFont_larger = preset.infoBoxChapterFont_larger
        self.infoBoxChapterFont_largest = preset.infoBoxChapterFont_largest
        
        self.trackTimesFont_normal = preset.trackTimesFont_normal
        self.trackTimesFont_larger = preset.trackTimesFont_larger
        self.trackTimesFont_largest = preset.trackTimesFont_largest
        
        self.feedbackFont_normal = preset.feedbackFont_normal
        self.feedbackFont_larger = preset.feedbackFont_larger
        self.feedbackFont_largest = preset.feedbackFont_largest
    }
    
    func applyFontSet(_ fontSet: PlayerFontSet) {
        
        self.infoBoxTitleFont_normal = fontSet.infoBoxTitleFont_normal
        self.infoBoxTitleFont_larger = fontSet.infoBoxTitleFont_larger
        self.infoBoxTitleFont_largest = fontSet.infoBoxTitleFont_largest
        
        self.infoBoxArtistAlbumFont_normal = fontSet.infoBoxArtistAlbumFont_normal
        self.infoBoxArtistAlbumFont_larger = fontSet.infoBoxArtistAlbumFont_larger
        self.infoBoxArtistAlbumFont_largest = fontSet.infoBoxArtistAlbumFont_largest
        
        self.infoBoxChapterFont_normal = fontSet.infoBoxChapterFont_normal
        self.infoBoxChapterFont_larger = fontSet.infoBoxChapterFont_larger
        self.infoBoxChapterFont_largest = fontSet.infoBoxChapterFont_largest
        
        self.trackTimesFont_normal = fontSet.trackTimesFont_normal
        self.trackTimesFont_larger = fontSet.trackTimesFont_larger
        self.trackTimesFont_largest = fontSet.trackTimesFont_largest
        
        self.feedbackFont_normal = fontSet.feedbackFont_normal
        self.feedbackFont_larger = fontSet.feedbackFont_larger
        self.feedbackFont_largest = fontSet.feedbackFont_largest
    }
}

class PlaylistFontSet {

    var trackTextFont_normal: NSFont
    var trackTextFont_larger: NSFont
    var trackTextFont_largest: NSFont
    
    var trackTextFont: NSFont {
        
        switch PlaylistViewState.textSize {
        
        case .normal: return trackTextFont_normal
            
        case .larger: return trackTextFont_larger
            
        case .largest: return trackTextFont_largest
            
        }
    }
    
    var groupTextFont_normal: NSFont
    var groupTextFont_larger: NSFont
    var groupTextFont_largest: NSFont
    
    var groupTextFont: NSFont {
        
        switch PlaylistViewState.textSize {
        
        case .normal: return groupTextFont_normal
            
        case .larger: return groupTextFont_larger
            
        case .largest: return groupTextFont_largest
            
        }
    }
    
    var summaryFont_normal: NSFont
    var summaryFont_larger: NSFont
    var summaryFont_largest: NSFont
    
    var summaryFont: NSFont {
        
        switch PlaylistViewState.textSize {
        
        case .normal: return summaryFont_normal
            
        case .larger: return summaryFont_larger
            
        case .largest: return summaryFont_largest
            
        }
    }

    var tabButtonTextFont_normal: NSFont
    var tabButtonTextFont_larger: NSFont
    var tabButtonTextFont_largest: NSFont

    var tabButtonTextFont: NSFont {
        
        switch PlaylistViewState.textSize {

        case .normal: return tabButtonTextFont_normal

        case .larger: return tabButtonTextFont_larger

        case .largest: return tabButtonTextFont_largest

        }
    }
    
    var chaptersListHeaderFont_normal: NSFont
    var chaptersListHeaderFont_larger: NSFont
    var chaptersListHeaderFont_largest: NSFont
     
    var chaptersListHeaderFont: NSFont {
        
        switch PlaylistViewState.textSize {

        case .normal: return chaptersListHeaderFont_normal

        case .larger: return chaptersListHeaderFont_larger

        case .largest: return chaptersListHeaderFont_largest

        }
    }
    
    var chaptersListSearchFont_normal: NSFont
    var chaptersListSearchFont_larger: NSFont
    var chaptersListSearchFont_largest: NSFont
     
    var chaptersListSearchFont: NSFont {
        
        switch PlaylistViewState.textSize {

        case .normal: return chaptersListSearchFont_normal

        case .larger: return chaptersListSearchFont_larger

        case .largest: return chaptersListSearchFont_largest

        }
    }
    
    var chaptersListCaptionFont_normal: NSFont
    var chaptersListCaptionFont_larger: NSFont
    var chaptersListCaptionFont_largest: NSFont
     
    var chaptersListCaptionFont: NSFont {
        
        switch PlaylistViewState.textSize {

        case .normal: return chaptersListCaptionFont_normal

        case .larger: return chaptersListCaptionFont_larger

        case .largest: return chaptersListCaptionFont_largest

        }
    }

    init(preset: FontSetPreset) {
        
        self.trackTextFont_normal = preset.playlistTrackTextFont_normal
        self.trackTextFont_larger = preset.playlistTrackTextFont_larger
        self.trackTextFont_largest = preset.playlistTrackTextFont_largest
        
        self.groupTextFont_normal = preset.playlistGroupTextFont_normal
        self.groupTextFont_larger = preset.playlistGroupTextFont_larger
        self.groupTextFont_largest = preset.playlistGroupTextFont_largest
        
        self.summaryFont_normal = preset.playlistSummaryFont_normal
        self.summaryFont_larger = preset.playlistSummaryFont_larger
        self.summaryFont_largest = preset.playlistSummaryFont_largest
        
        self.tabButtonTextFont_normal = preset.playlistTabButtonTextFont_normal
        self.tabButtonTextFont_larger = preset.playlistTabButtonTextFont_larger
        self.tabButtonTextFont_largest = preset.playlistTabButtonTextFont_largest
        
        self.chaptersListHeaderFont_normal = preset.chaptersListHeaderFont_normal
        self.chaptersListHeaderFont_larger = preset.chaptersListHeaderFont_larger
        self.chaptersListHeaderFont_largest = preset.chaptersListHeaderFont_largest
        
        self.chaptersListSearchFont_normal = preset.chaptersListSearchFont_normal
        self.chaptersListSearchFont_larger = preset.chaptersListSearchFont_larger
        self.chaptersListSearchFont_largest = preset.chaptersListSearchFont_largest
        
        self.chaptersListCaptionFont_normal = preset.chaptersListCaptionFont_normal
        self.chaptersListCaptionFont_larger = preset.chaptersListCaptionFont_larger
        self.chaptersListCaptionFont_largest = preset.chaptersListCaptionFont_largest
    }
    
    func applyFontSet(_ fontSet: PlaylistFontSet) {
        
        self.trackTextFont_normal = fontSet.trackTextFont_normal
        self.trackTextFont_larger = fontSet.trackTextFont_larger
        self.trackTextFont_largest = fontSet.trackTextFont_largest
        
        self.groupTextFont_normal = fontSet.groupTextFont_normal
        self.groupTextFont_larger = fontSet.groupTextFont_larger
        self.groupTextFont_largest = fontSet.groupTextFont_largest
        
        self.summaryFont_normal = fontSet.summaryFont_normal
        self.summaryFont_larger = fontSet.summaryFont_larger
        self.summaryFont_largest = fontSet.summaryFont_largest
        
        self.tabButtonTextFont_normal = fontSet.tabButtonTextFont_normal
        self.tabButtonTextFont_larger = fontSet.tabButtonTextFont_larger
        self.tabButtonTextFont_largest = fontSet.tabButtonTextFont_largest
        
        self.chaptersListHeaderFont_normal = fontSet.chaptersListHeaderFont_normal
        self.chaptersListHeaderFont_larger = fontSet.chaptersListHeaderFont_larger
        self.chaptersListHeaderFont_largest = fontSet.chaptersListHeaderFont_largest
        
        self.chaptersListSearchFont_normal = fontSet.chaptersListSearchFont_normal
        self.chaptersListSearchFont_larger = fontSet.chaptersListSearchFont_larger
        self.chaptersListSearchFont_largest = fontSet.chaptersListSearchFont_largest
        
        self.chaptersListCaptionFont_normal = fontSet.chaptersListCaptionFont_normal
        self.chaptersListCaptionFont_larger = fontSet.chaptersListCaptionFont_larger
        self.chaptersListCaptionFont_largest = fontSet.chaptersListCaptionFont_largest
    }
}

class EffectsFontSet {

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
