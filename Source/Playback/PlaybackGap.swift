import Foundation

class PlaybackGap: Hashable {
    
    // For identity when hashing
    let id: Int
    
    var duration: Double
    var position: PlaybackGapPosition
    var type: PlaybackGapType
    
    convenience init(_ duration: Double, _ position: PlaybackGapPosition) {
        self.init(duration, position, .persistent)
    }
    
    init(_ duration: Double, _ position: PlaybackGapPosition, _ type: PlaybackGapType) {
        
        self.id = Int.random(in: 0 ... Int.max)
        
        self.duration = duration
        self.position = position
        self.type = type
    }
    
    static func == (lhs: PlaybackGap, rhs: PlaybackGap) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Needed for Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

enum PlaybackGapPosition: String {
    
    case beforeTrack
    case afterTrack
}

enum PlaybackGapType: String {
    
    // Explicit gap types as defined by the user per-track (i.e. applies to a single playlist track)
    case oneTime
    case tillAppExits
    case persistent
    
    // Implicit gap as specified by Playback preferences (i.e. applies to all playlist tracks)
    case implicit
}
