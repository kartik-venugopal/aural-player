import Cocoa

struct Dimensions {
 
    // Values used to determine the row height of table rows in the detailed track info popover view
    static let trackInfoKeyColumnWidth: CGFloat = 135
    static let trackInfoValueColumnWidth: CGFloat = 365
    
    // Window width (never changes)
    static let windowWidth: CGFloat = 480
    static let minPlaylistWidth: CGFloat = 480
    static let minPlaylistHeight: CGFloat = 180
    
    static let snapProximity: CGFloat = 15
}

enum TextSizeScheme: String {
    
    case normal
    case larger
    case largest
}

class TextSizes {
    
    static var playerScheme: TextSizeScheme = .normal
    static var effectsScheme: TextSizeScheme = .normal
    static var playlistScheme: TextSizeScheme = .normal
    
    private static let menuFont_normal: NSFont = Fonts.gillSans11Font
    private static let menuFont_larger: NSFont = Fonts.gillSans12Font
    private static let menuFont_largest: NSFont = Fonts.gillSans13Font
    
    static var playerMenuFont: NSFont {
        
        switch playerScheme {
            
        case .normal: return menuFont_normal
            
        case .larger: return menuFont_larger
            
        case .largest: return menuFont_largest
            
        }
    }
    
    static var playlistMenuFont: NSFont {
        
        switch playlistScheme {
            
        case .normal: return menuFont_normal
            
        case .larger: return menuFont_larger
            
        case .largest: return menuFont_largest
            
        }
    }
    
    static var effectsMenuFont: NSFont {
        
        switch effectsScheme {
            
        case .normal: return menuFont_normal
            
        case .larger: return menuFont_larger
            
        case .largest: return menuFont_largest
            
        }
    }
    
    private static let titleFont_normal: NSFont = NSFont(name: "Gill Sans Semibold", size: 16)!
    private static let titleFont_larger: NSFont = NSFont(name: "Gill Sans Semibold", size: 18)!
    private static let titleFont_largest: NSFont = NSFont(name: "Gill Sans Semibold", size: 20)!
    
    static var titleFont: NSFont {
        
        switch playerScheme {
            
        case .normal: return titleFont_normal
            
        case .larger: return titleFont_larger
            
        case .largest: return titleFont_largest
            
        }
    }
    
    private static let gapBoxTitleFont_normal: NSFont = NSFont(name: "Gill Sans Semibold", size: 14)!
    private static let gapBoxTitleFont_larger: NSFont = NSFont(name: "Gill Sans Semibold", size: 15)!
    private static let gapBoxTitleFont_largest: NSFont = NSFont(name: "Gill Sans Semibold", size: 16)!
    
    static var gapBoxTitleFont: NSFont {
        
        switch playerScheme {
            
        case .normal: return gapBoxTitleFont_normal
            
        case .larger: return gapBoxTitleFont_larger
            
        case .largest: return gapBoxTitleFont_largest
            
        }
    }
    
    private static let artistFont_normal: NSFont = NSFont(name: "Gill Sans Semibold", size: 14)!
    private static let artistFont_larger: NSFont = NSFont(name: "Gill Sans Semibold", size: 16)!
    private static let artistFont_largest: NSFont = NSFont(name: "Gill Sans Semibold", size: 18)!
    
    static var artistFont: NSFont {
        
        switch playerScheme {
            
        case .normal: return artistFont_normal
            
        case .larger: return artistFont_larger
            
        case .largest: return artistFont_largest
            
        }
    }
    
    private static let scopeFont_normal: NSFont = NSFont(name: "Gill Sans", size: 10)!
    private static let scopeFont_larger: NSFont = NSFont(name: "Gill Sans", size: 12)!
    private static let scopeFont_largest: NSFont = NSFont(name: "Gill Sans", size: 14)!
    
    static var scopeFont: NSFont {
        
        switch playerScheme {
            
        case .normal: return scopeFont_normal
            
        case .larger: return scopeFont_larger
            
        case .largest: return scopeFont_largest
            
        }
    }
    
    private static let trackTimesFont_normal: NSFont = NSFont(name: "Gill Sans Semibold", size: 12)!
    private static let trackTimesFont_larger: NSFont = NSFont(name: "Gill Sans Semibold", size: 13)!
    private static let trackTimesFont_largest: NSFont = NSFont(name: "Gill Sans Semibold", size: 14)!
    
    static var trackTimesFont: NSFont {
        
        switch playerScheme {
            
        case .normal: return trackTimesFont_normal
            
        case .larger: return trackTimesFont_larger
            
        case .largest: return trackTimesFont_largest
            
        }
    }
    
    private static let feedbackFont_normal: NSFont = NSFont(name: "Gill Sans Semibold", size: 10)!
    private static let feedbackFont_larger: NSFont = NSFont(name: "Gill Sans Semibold", size: 11)!
    private static let feedbackFont_largest: NSFont = NSFont(name: "Gill Sans Semibold", size: 12)!
    
    static var feedbackFont: NSFont {
        
        switch playerScheme {
            
        case .normal: return feedbackFont_normal
            
        case .larger: return feedbackFont_larger
            
        case .largest: return feedbackFont_largest
            
        }
    }
    
    private static let playlistIndexFont_normal: NSFont = NSFont(name: "Gill Sans", size: 13)!
    private static let playlistIndexFont_larger: NSFont = NSFont(name: "Gill Sans", size: 14)!
    private static let playlistIndexFont_largest: NSFont = NSFont(name: "Gill Sans", size: 15)!
    
    static var playlistIndexFont: NSFont {
        
        switch playlistScheme {
            
        case .normal: return playlistIndexFont_normal
            
        case .larger: return playlistIndexFont_larger
            
        case .largest: return playlistIndexFont_largest
            
        }
    }
    
    private static let playlistTrackNameFont_normal: NSFont = NSFont(name: "Gill Sans", size: 13)!
    private static let playlistTrackNameFont_larger: NSFont = NSFont(name: "Gill Sans", size: 14)!
    private static let playlistTrackNameFont_largest: NSFont = NSFont(name: "Gill Sans", size: 15)!
    
    static var playlistTrackNameFont: NSFont {
        
        switch playlistScheme {
            
        case .normal: return playlistTrackNameFont_normal
            
        case .larger: return playlistTrackNameFont_larger
            
        case .largest: return playlistTrackNameFont_largest
            
        }
    }
    
    private static let playlistGroupNameFont_normal: NSFont = NSFont(name: "Gill Sans Semibold", size: 13.5)!
    private static let playlistGroupNameFont_larger: NSFont = NSFont(name: "Gill Sans Semibold", size: 14.5)!
    private static let playlistGroupNameFont_largest: NSFont = NSFont(name: "Gill Sans Semibold", size: 15.5)!
    
    static var playlistGroupNameFont: NSFont {
        
        switch playlistScheme {
            
        case .normal: return playlistGroupNameFont_normal
            
        case .larger: return playlistGroupNameFont_larger
            
        case .largest: return playlistGroupNameFont_largest
            
        }
    }

    private static let playlistGroupDurationFont_normal: NSFont = NSFont(name: "Gill Sans Semibold", size: 13.5)!
    private static let playlistGroupDurationFont_larger: NSFont = NSFont(name: "Gill Sans Semibold", size: 14.5)!
    private static let playlistGroupDurationFont_largest: NSFont = NSFont(name: "Gill Sans Semibold", size: 15.5)!

    static var playlistGroupDurationFont: NSFont {

        switch playlistScheme {

        case .normal: return playlistGroupDurationFont_normal

        case .larger: return playlistGroupDurationFont_larger

        case .largest: return playlistGroupDurationFont_largest

        }
    }
    
    private static let playlistSummaryFont_normal: NSFont = NSFont(name: "Gill Sans Semibold", size: 13)!
    private static let playlistSummaryFont_larger: NSFont = NSFont(name: "Gill Sans Semibold", size: 14)!
    private static let playlistSummaryFont_largest: NSFont = NSFont(name: "Gill Sans Semibold", size: 15)!
    
    static var playlistSummaryFont: NSFont {
        
        switch playlistScheme {
            
        case .normal: return playlistSummaryFont_normal
            
        case .larger: return playlistSummaryFont_larger
            
        case .largest: return playlistSummaryFont_largest
            
        }
    }
    
    private static let playlistTabsFont_normal: NSFont = Fonts.gillSans13Font
    private static let playlistTabsFont_larger: NSFont = Fonts.gillSans14Font
    private static let playlistTabsFont_largest: NSFont = Fonts.gillSans15Font
    
    static var playlistTabsFont: NSFont {
        
        switch playlistScheme {
            
        case .normal: return playlistTabsFont_normal
            
        case .larger: return playlistTabsFont_larger
            
        case .largest: return playlistTabsFont_largest
            
        }
    }
    
    private static let playlistSelectedTabFont_normal: NSFont = Fonts.gillSans13SemiBoldFont
    private static let playlistSelectedTabFont_larger: NSFont = NSFont(name: "Gill Sans Semibold", size: 14)!
    private static let playlistSelectedTabFont_largest: NSFont = NSFont(name: "Gill Sans Semibold", size: 15)!
    
    static var playlistSelectedTabFont: NSFont {
        
        switch playlistScheme {
            
        case .normal: return playlistSelectedTabFont_normal
            
        case .larger: return playlistSelectedTabFont_larger
            
        case .largest: return playlistSelectedTabFont_largest
            
        }
    }
    
    private static let fxTabsFont_normal: NSFont = Fonts.gillSans12Font
    private static let fxTabsFont_larger: NSFont = Fonts.gillSans13Font
    private static let fxTabsFont_largest: NSFont = Fonts.gillSans14Font
    
    static var fxTabsFont: NSFont {
        
        switch effectsScheme {
            
        case .normal: return fxTabsFont_normal
            
        case .larger: return fxTabsFont_larger
            
        case .largest: return fxTabsFont_largest
            
        }
    }
    
    private static let fxSelectedTabFont_normal: NSFont = Fonts.gillSans12SemiBoldFont
    private static let fxSelectedTabFont_larger: NSFont = Fonts.gillSans13SemiBoldFont
    private static let fxSelectedTabFont_largest: NSFont = NSFont(name: "Gill Sans Semibold", size: 14)!
    
    static var fxSelectedTabFont: NSFont {
        
        switch effectsScheme {
            
        case .normal: return fxSelectedTabFont_normal
            
        case .larger: return fxSelectedTabFont_larger
            
        case .largest: return fxSelectedTabFont_largest
            
        }
    }
    
    private static let fxUnitCaptionFont_normal: NSFont = NSFont(name: "Gill Sans", size: 14)!
    private static let fxUnitCaptionFont_larger: NSFont = NSFont(name: "Gill Sans", size: 16)!
    private static let fxUnitCaptionFont_largest: NSFont = NSFont(name: "Gill Sans", size: 18)!
    
    static var fxUnitCaptionFont: NSFont {
        
        switch effectsScheme {
            
        case .normal: return fxUnitCaptionFont_normal
            
        case .larger: return fxUnitCaptionFont_larger
            
        case .largest: return fxUnitCaptionFont_largest
            
        }
    }

    private static let fxUnitFunctionFont_normal: NSFont = NSFont(name: "Gill Sans", size: 11)!
    private static let fxUnitFunctionFont_larger: NSFont = NSFont(name: "Gill Sans", size: 12)!
    private static let fxUnitFunctionFont_largest: NSFont = NSFont(name: "Gill Sans", size: 13)!
    
    static var fxUnitFunctionFont: NSFont {
        
        switch effectsScheme {
            
        case .normal: return fxUnitFunctionFont_normal
            
        case .larger: return fxUnitFunctionFont_larger
            
        case .largest: return fxUnitFunctionFont_largest
            
        }
    }
    
    private static let fxUnitFunctionBoldFont_normal: NSFont = NSFont(name: "Gill Sans SemiBold", size: 11)!
    private static let fxUnitFunctionBoldFont_larger: NSFont = NSFont(name: "Gill Sans SemiBold", size: 12)!
    private static let fxUnitFunctionBoldFont_largest: NSFont = NSFont(name: "Gill Sans SemiBold", size: 13)!
    
    static var fxUnitFunctionBoldFont: NSFont {
        
        switch effectsScheme {
            
        case .normal: return fxUnitFunctionBoldFont_normal
            
        case .larger: return fxUnitFunctionBoldFont_larger
            
        case .largest: return fxUnitFunctionBoldFont_largest
            
        }
    }
    
    private static let filterChartFont_normal: NSFont = NSFont(name: "Gill Sans SemiBold", size: 9)!
    private static let filterChartFont_larger: NSFont = NSFont(name: "Gill Sans SemiBold", size: 10)!
    private static let filterChartFont_largest: NSFont = NSFont(name: "Gill Sans SemiBold", size: 11)!
    
    static var filterChartFont: NSFont {
        
        switch effectsScheme {
            
        case .normal: return filterChartFont_normal
            
        case .larger: return filterChartFont_larger
            
        case .largest: return filterChartFont_largest
            
        }
    }
    
    private static let stringInputPopoverFont_normal: NSFont = NSFont(name: "Gill Sans", size: 12)!
    private static let stringInputPopoverFont_larger: NSFont = NSFont(name: "Gill Sans", size: 13)!
    private static let stringInputPopoverFont_largest: NSFont = NSFont(name: "Gill Sans", size: 14)!
    
    static func stringInputPopoverFont(_ size: TextSizeScheme) -> NSFont {
        
        switch size {
            
        case .normal: return stringInputPopoverFont_normal
            
        case .larger: return stringInputPopoverFont_larger
            
        case .largest: return stringInputPopoverFont_largest
            
        }
    }
    
    private static let stringInputPopoverErrorFont_normal: NSFont = NSFont(name: "Gill Sans", size: 11)!
    private static let stringInputPopoverErrorFont_larger: NSFont = NSFont(name: "Gill Sans", size: 12)!
    private static let stringInputPopoverErrorFont_largest: NSFont = NSFont(name: "Gill Sans", size: 13)!
    
    static func stringInputPopoverErrorFont(_ size: TextSizeScheme) -> NSFont {
        
        switch size {
            
        case .normal: return stringInputPopoverErrorFont_normal
            
        case .larger: return stringInputPopoverErrorFont_larger
            
        case .largest: return stringInputPopoverErrorFont_largest
            
        }
    }
}
