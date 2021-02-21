import Foundation

/*
    An object that temporarily holds font settings used when applying a new customized font set to the app. It is used by the font set customization dialog when the user makes changes and clicks "Apply changes".
 */
class FontSetChangeContext {
    
    var textFontName: String = Fonts.Standard.mainFont_8.fontName
    var headingFontName: String = Fonts.Standard.captionFont_13.fontName
    
    var infoBoxTitle_normalSize: CGFloat = FontSetPreset.standard.infoBoxTitleFont_normal.pointSize
    var infoBoxTitle_largerSize: CGFloat = FontSetPreset.standard.infoBoxTitleFont_larger.pointSize
    var infoBoxTitle_largestSize: CGFloat = FontSetPreset.standard.infoBoxTitleFont_largest.pointSize
    
    var infoBoxArtistAlbum_normalSize: CGFloat = FontSetPreset.standard.infoBoxArtistAlbumFont_normal.pointSize
    var infoBoxArtistAlbum_largerSize: CGFloat = FontSetPreset.standard.infoBoxArtistAlbumFont_larger.pointSize
    var infoBoxArtistAlbum_largestSize: CGFloat = FontSetPreset.standard.infoBoxArtistAlbumFont_largest.pointSize
    
    var infoBoxChapter_normalSize: CGFloat = FontSetPreset.standard.infoBoxChapterTitleFont_normal.pointSize
    var infoBoxChapter_largerSize: CGFloat = FontSetPreset.standard.infoBoxChapterTitleFont_larger.pointSize
    var infoBoxChapter_largestSize: CGFloat = FontSetPreset.standard.infoBoxChapterTitleFont_largest.pointSize
    
    var trackTimes_normalSize: CGFloat = FontSetPreset.standard.trackTimesFont_normal.pointSize
    var trackTimes_largerSize: CGFloat = FontSetPreset.standard.trackTimesFont_larger.pointSize
    var trackTimes_largestSize: CGFloat = FontSetPreset.standard.trackTimesFont_largest.pointSize
    
    var feedback_normalSize: CGFloat = FontSetPreset.standard.feedbackFont_normal.pointSize
    var feedback_largerSize: CGFloat = FontSetPreset.standard.feedbackFont_larger.pointSize
    var feedback_largestSize: CGFloat = FontSetPreset.standard.feedbackFont_largest.pointSize
    
    var trackText_normalSize: CGFloat = FontSetPreset.standard.playlistTrackTextFont_normal.pointSize
    var trackText_largerSize: CGFloat = FontSetPreset.standard.playlistTrackTextFont_larger.pointSize
    var trackText_largestSize: CGFloat = FontSetPreset.standard.playlistTrackTextFont_largest.pointSize
   
    var groupText_normalSize: CGFloat = FontSetPreset.standard.playlistGroupTextFont_normal.pointSize
    var groupText_largerSize: CGFloat = FontSetPreset.standard.playlistGroupTextFont_larger.pointSize
    var groupText_largestSize: CGFloat = FontSetPreset.standard.playlistGroupTextFont_largest.pointSize
    
    var summary_normalSize: CGFloat = FontSetPreset.standard.playlistSummaryFont_normal.pointSize
    var summary_largerSize: CGFloat = FontSetPreset.standard.playlistSummaryFont_larger.pointSize
    var summary_largestSize: CGFloat = FontSetPreset.standard.playlistSummaryFont_largest.pointSize
    
    var tabButtonText_normalSize: CGFloat = FontSetPreset.standard.playlistTabButtonTextFont_normal.pointSize
    var tabButtonText_largerSize: CGFloat = FontSetPreset.standard.playlistTabButtonTextFont_larger.pointSize
    var tabButtonText_largestSize: CGFloat = FontSetPreset.standard.playlistTabButtonTextFont_largest.pointSize

    var chaptersListHeader_normalSize: CGFloat = FontSetPreset.standard.chaptersListHeaderFont_normal.pointSize
    var chaptersListHeader_largerSize: CGFloat = FontSetPreset.standard.chaptersListHeaderFont_larger.pointSize
    var chaptersListHeader_largestSize: CGFloat = FontSetPreset.standard.chaptersListHeaderFont_largest.pointSize
    
    var chaptersListSearch_normalSize: CGFloat = FontSetPreset.standard.chaptersListSearchFont_normal.pointSize
    var chaptersListSearch_largerSize: CGFloat = FontSetPreset.standard.chaptersListSearchFont_larger.pointSize
    var chaptersListSearch_largestSize: CGFloat = FontSetPreset.standard.chaptersListSearchFont_largest.pointSize
    
    var chaptersListCaption_normalSize: CGFloat = FontSetPreset.standard.chaptersListCaptionFont_normal.pointSize
    var chaptersListCaption_largerSize: CGFloat = FontSetPreset.standard.chaptersListCaptionFont_larger.pointSize
    var chaptersListCaption_largestSize: CGFloat = FontSetPreset.standard.chaptersListCaptionFont_largest.pointSize
    
    var unitCaption_normalSize: CGFloat = FontSetPreset.standard.effectsUnitCaptionFont_normal.pointSize
    var unitCaption_largerSize: CGFloat = FontSetPreset.standard.effectsUnitCaptionFont_larger.pointSize
    var unitCaption_largestSize: CGFloat = FontSetPreset.standard.effectsUnitCaptionFont_largest.pointSize
    
    var unitFunction_normalSize: CGFloat = FontSetPreset.standard.effectsUnitFunctionFont_normal.pointSize
    var unitFunction_largerSize: CGFloat = FontSetPreset.standard.effectsUnitFunctionFont_larger.pointSize
    var unitFunction_largestSize: CGFloat = FontSetPreset.standard.effectsUnitFunctionFont_largest.pointSize
   
    var masterUnitFunction_normalSize: CGFloat = FontSetPreset.standard.effectsMasterUnitFunctionFont_normal.pointSize
    var masterUnitFunction_largerSize: CGFloat = FontSetPreset.standard.effectsMasterUnitFunctionFont_larger.pointSize
    var masterUnitFunction_largestSize: CGFloat = FontSetPreset.standard.effectsMasterUnitFunctionFont_largest.pointSize
    
    var filterChart_normalSize: CGFloat = FontSetPreset.standard.effectsFilterChartFont_normal.pointSize
    var filterChart_largerSize: CGFloat = FontSetPreset.standard.effectsFilterChartFont_larger.pointSize
    var filterChart_largestSize: CGFloat = FontSetPreset.standard.effectsFilterChartFont_largest.pointSize
}
