import Foundation

/*
    Represents a gap in playback that can be defined in the playlist.
    A gap can be positioned before or after a track, in the playlist.
 */
class PlaybackGap: Equatable {
    
    // For identity when comparing instances
    let id: Int
    
    var duration: Double
    var position: PlaybackGapPosition
    var type: PlaybackGapType
    
    init(_ duration: Double, _ position: PlaybackGapPosition, _ type: PlaybackGapType = .persistent) {
        
        self.id = Int.random(in: 0 ... Int.max)
        
        self.duration = duration
        self.position = position
        self.type = type
    }
    
    static func == (lhs: PlaybackGap, rhs: PlaybackGap) -> Bool {
        return lhs.id == rhs.id
    }
}

// Describes the position of a playback gap relative to a playlist track
enum PlaybackGapPosition: String {
    
    case beforeTrack
    case afterTrack
}

// The type of a playback gap, which determines its behavior
enum PlaybackGapType: String {
    
    // The first 3 "explicit" gap types below are defined by the user per-track (i.e. apply to a single playlist track)
    
    // Gap takes effect only once, after which it is automatically removed from the playlist
    case oneTime
    
    // Gap takes effect as long as the app is open. When the app exits, it is not persisted.
    case tillAppExits
    
    // Gap persists across app launches.
    case persistent
    
    // Implicit gap as specified by the playback preferences (i.e. applies to all playlist tracks)
    // Takes effect as long as the relevant gap preference is enabled.
    case implicit
}
