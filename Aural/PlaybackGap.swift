import Foundation

class PlaybackGap {
    
    let duration: Double
    let position: PlaybackGapPosition
    
    init(_ duration: Double, _ position: PlaybackGapPosition) {
        self.duration = duration
        self.position = position
    }
}

enum PlaybackGapPosition {
    
    case beforeTrack
    case afterTrack
}
