import Cocoa

struct Dimensions {
 
    // Values used to determine the row height of table rows in the detailed track info popover view
    static let trackInfoKeyColumnWidth: CGFloat = 135
    static let trackInfoValueColumnWidth: CGFloat = 365
    
    // Main window size (never changes)
    static let mainWindowWidth: CGFloat = 530
    static let mainWindowHeight: CGFloat = 230
    
    // Effects window size (never changes)
    static let effectsWindowWidth: CGFloat = 530
    static let effectsWindowHeight: CGFloat = 230
    
    static let minPlaylistWidth: CGFloat = 530
    static let minPlaylistHeight: CGFloat = 180
    
    static let snapProximity: CGFloat = 15
    
    static let historyMenuItemImageSize: NSSize = NSSize(width: 22, height: 22)
}

enum TextSize: String {
    
    case normal
    case larger
    case largest
}

// A contract for any UI component whose text size can be altered.
protocol TextSizeable {
    
    // Change the text font size of this component to the given size.
    func changeTextSize(_ size: TextSize)
}
