import Cocoa

struct Dimensions {
 
    // Height values for the Track Name label, depending on whether it is displaying one or two lines of text
    static let trackNameLabelHeight_oneLine: CGFloat = 25
    static let trackNameLabelHeight_twoLines: CGFloat = 40
    
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
    static var playlistScheme: TextSizeScheme = .normal
    
    private static let titleFont_normal: NSFont = NSFont(name: "Gill Sans Semibold", size: 14)!
    private static let titleFont_larger: NSFont = NSFont(name: "Gill Sans Semibold", size: 16)!
    private static let titleFont_largest: NSFont = NSFont(name: "Gill Sans Semibold", size: 18)!
    
    static var titleFont: NSFont {
        
        switch playerScheme {
            
        case .normal: return titleFont_normal
            
        case .larger: return titleFont_larger
            
        case .largest: return titleFont_largest
            
        }
    }
    
    private static let artistFont_normal: NSFont = NSFont(name: "Gill Sans", size: 12)!
    private static let artistFont_larger: NSFont = NSFont(name: "Gill Sans", size: 14)!
    private static let artistFont_largest: NSFont = NSFont(name: "Gill Sans", size: 16)!
    
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
    
    private static let trackTimesFont_normal: NSFont = NSFont(name: "Gill Sans", size: 10)!
    private static let trackTimesFont_larger: NSFont = NSFont(name: "Gill Sans", size: 11)!
    private static let trackTimesFont_largest: NSFont = NSFont(name: "Gill Sans", size: 12)!
    
    static var trackTimesFont: NSFont {
        
        switch playerScheme {
            
        case .normal: return trackTimesFont_normal
            
        case .larger: return trackTimesFont_larger
            
        case .largest: return trackTimesFont_largest
            
        }
    }
    
    private static let feedbackFont_normal: NSFont = NSFont(name: "Gill Sans Semibold", size: 8)!
    private static let feedbackFont_larger: NSFont = NSFont(name: "Gill Sans Semibold", size: 9)!
    private static let feedbackFont_largest: NSFont = NSFont(name: "Gill Sans Semibold", size: 10)!
    
    static var feedbackFont: NSFont {
        
        switch playerScheme {
            
        case .normal: return feedbackFont_normal
            
        case .larger: return feedbackFont_larger
            
        case .largest: return feedbackFont_largest
            
        }
    }
    
    private static let playlistIndexFont_normal: NSFont = NSFont(name: "Gill Sans Semibold", size: 12)!
    private static let playlistIndexFont_larger: NSFont = NSFont(name: "Gill Sans Semibold", size: 13)!
    private static let playlistIndexFont_largest: NSFont = NSFont(name: "Gill Sans Semibold", size: 14)!
    
    static var playlistIndexFont: NSFont {
        
        switch playlistScheme {
            
        case .normal: return playlistIndexFont_normal
            
        case .larger: return playlistIndexFont_larger
            
        case .largest: return playlistIndexFont_largest
            
        }
    }
    
    private static let playlistGroupNameFont_normal: NSFont = NSFont(name: "Gill Sans", size: 12.5)!
    private static let playlistGroupNameFont_larger: NSFont = NSFont(name: "Gill Sans", size: 13.5)!
    private static let playlistGroupNameFont_largest: NSFont = NSFont(name: "Gill Sans", size: 14.5)!
    
    static var playlistGroupNameFont: NSFont {
        
        switch playlistScheme {
            
        case .normal: return playlistGroupNameFont_normal
            
        case .larger: return playlistGroupNameFont_larger
            
        case .largest: return playlistGroupNameFont_largest
            
        }
    }
    
    private static let playlistGroupDurationFont_normal: NSFont = NSFont(name: "Gill Sans Semibold", size: 12.5)!
    private static let playlistGroupDurationFont_larger: NSFont = NSFont(name: "Gill Sans Semibold", size: 13.5)!
    private static let playlistGroupDurationFont_largest: NSFont = NSFont(name: "Gill Sans Semibold", size: 14.5)!
    
    static var playlistGroupDurationFont: NSFont {
        
        switch playlistScheme {
            
        case .normal: return playlistGroupDurationFont_normal
            
        case .larger: return playlistGroupDurationFont_larger
            
        case .largest: return playlistGroupDurationFont_largest
            
        }
    }
    
    private static let playlistSelectedGroupNameFont_normal: NSFont = NSFont(name: "Gill Sans Semibold", size: 12.5)!
    private static let playlistSelectedGroupNameFont_larger: NSFont = NSFont(name: "Gill Sans Semibold", size: 13.5)!
    private static let playlistSelectedGroupNameFont_largest: NSFont = NSFont(name: "Gill Sans Semibold", size: 14.5)!
    
    static var playlistSelectedGroupNameFont: NSFont {
        
        switch playlistScheme {
            
        case .normal: return playlistSelectedGroupNameFont_normal
            
        case .larger: return playlistSelectedGroupNameFont_larger
            
        case .largest: return playlistSelectedGroupNameFont_largest
            
        }
    }
    
    private static let playlistTrackNameFont_normal: NSFont = NSFont(name: "Gill Sans", size: 12)!
    private static let playlistTrackNameFont_larger: NSFont = NSFont(name: "Gill Sans", size: 13)!
    private static let playlistTrackNameFont_largest: NSFont = NSFont(name: "Gill Sans", size: 14)!
    
    static var playlistTrackNameFont: NSFont {
        
        switch playlistScheme {
            
        case .normal: return playlistTrackNameFont_normal
            
        case .larger: return playlistTrackNameFont_larger
            
        case .largest: return playlistTrackNameFont_largest
            
        }
    }
    
    private static let playlistSelectedTrackNameFont_normal: NSFont = NSFont(name: "Gill Sans Semibold", size: 12)!
    private static let playlistSelectedTrackNameFont_larger: NSFont = NSFont(name: "Gill Sans Semibold", size: 13)!
    private static let playlistSelectedTrackNameFont_largest: NSFont = NSFont(name: "Gill Sans Semibold", size: 14)!
    
    static var playlistSelectedTrackNameFont: NSFont {
        
        switch playlistScheme {
            
        case .normal: return playlistSelectedTrackNameFont_normal
            
        case .larger: return playlistSelectedTrackNameFont_larger
            
        case .largest: return playlistSelectedTrackNameFont_largest
            
        }
    }
}
