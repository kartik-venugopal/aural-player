import Foundation

// Convenient accessor for the current state of the player UI
class PlayerViewState {
    
    static var viewType: PlayerViewType = .defaultView
    
    // Settings for individual track metadata fields
    
    static var showAlbumArt: Bool = PlayerViewDefaults.showAlbumArt
    static var showArtist: Bool = PlayerViewDefaults.showArtist
    static var showAlbum: Bool = PlayerViewDefaults.showAlbum
    static var showCurrentChapter: Bool = PlayerViewDefaults.showCurrentChapter
    
    static var showTrackInfo: Bool = PlayerViewDefaults.showTrackInfo
    
    static var showPlayingTrackFunctions: Bool = PlayerViewDefaults.showPlayingTrackFunctions
    static var showControls: Bool = PlayerViewDefaults.showControls
    static var showTimeElapsedRemaining: Bool = PlayerViewDefaults.showTimeElapsedRemaining
    
    static var timeElapsedDisplayType: TimeElapsedDisplayType = PlayerViewDefaults.timeElapsedDisplayType
    static var timeRemainingDisplayType: TimeRemainingDisplayType = PlayerViewDefaults.timeRemainingDisplayType
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
