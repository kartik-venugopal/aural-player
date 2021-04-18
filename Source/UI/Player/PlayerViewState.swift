import Foundation

// Convenient accessor for the current state of the player UI
class PlayerViewState {
    
    static var viewType: PlayerViewType = .defaultView
    
    // Settings for individual track metadata fields
    
    static var showAlbumArt: Bool = true
    static var showArtist: Bool = true
    static var showAlbum: Bool = true
    static var showCurrentChapter: Bool = true
    
    static var showTrackInfo: Bool = true
    
    static var showPlayingTrackFunctions: Bool = true
    static var showControls: Bool = true
    static var showTimeElapsedRemaining: Bool = true
    
    static var timeElapsedDisplayType: TimeElapsedDisplayType = .formatted
    static var timeRemainingDisplayType: TimeRemainingDisplayType = .formatted
}

class StatusBarPlayerViewState {
    
    static var showAlbumArt: Bool = true
    static var showArtist: Bool = true
    static var showAlbum: Bool = true
    static var showCurrentChapter: Bool = true
}

enum PlayerViewType: String {
    
    case defaultView
    case expandedArt
}
