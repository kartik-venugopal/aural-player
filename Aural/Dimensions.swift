import Cocoa

struct Dimensions {
 
    // Height values for the Track Name label, depending on whether it is displaying one or two lines of text
    static let trackNameLabelHeight_oneLine: CGFloat = 25
    static let trackNameLabelHeight_twoLines: CGFloat = 40
    
    // Values used to determine the row height of table rows in the detailed track info popover view
    static let trackInfoKeyColumnWidth: CGFloat = 125
    static let trackInfoValueColumnWidth: CGFloat = 315
    
    // Window width (never changes)
    static let windowWidth: CGFloat = 480
    static let minPlaylistWidth: CGFloat = 480
    static let minPlaylistHeight: CGFloat = 180
    
    // Window heights for different views
    static let windowHeight_compact: CGFloat = 230
    static let windowHeight_playlistAndEffects: CGFloat = 408
    static let windowHeight_playlistOnly: CGFloat = 218
    static let windowHeight_effectsOnly: CGFloat = 420
    
    static let snapProximity: CGFloat = 15
}
