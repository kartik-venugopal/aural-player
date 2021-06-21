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

struct PlayerViewDefaults {
    
    static let viewType: PlayerViewType = .defaultView
    
    static let showAlbumArt: Bool = true
    static let showArtist: Bool = true
    static let showAlbum: Bool = true
    static let showCurrentChapter: Bool = true
    
    static let showTrackInfo: Bool = true
    static let showSequenceInfo: Bool = true
    
    static let showPlayingTrackFunctions: Bool = true
    static let showControls: Bool = true
    static let showTimeElapsedRemaining: Bool = true
    
    static let timeElapsedDisplayType: TimeElapsedDisplayType = .formatted
    static let timeRemainingDisplayType: TimeRemainingDisplayType = .formatted
}

enum PlayerViewType: String {
    
    case defaultView
    case expandedArt
}
