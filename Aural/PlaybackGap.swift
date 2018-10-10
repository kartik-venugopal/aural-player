import Foundation

class PlaybackGap {
    
    // For identity when hashing
    let id: Int
    
    var duration: Double
    var position: PlaybackGapPosition
    
    init(_ duration: Double, _ position: PlaybackGapPosition) {
        
        self.id = Int.random(in: 0 ... Int.max)
        
        self.duration = duration
        self.position = position
    }
}

enum PlaybackGapPosition {
    
    case beforeTrack
    case afterTrack
}

extension PlaybackGap: Hashable {
    
    static func == (lhs: PlaybackGap, rhs: PlaybackGap) -> Bool {
        return lhs.id == rhs.id
    }
    
    var hashValue: Int {
        return self.id
    }
}
