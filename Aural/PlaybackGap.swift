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

class PlaybackGapContext {
    
    private static var id: Int = -1
    private static var gaps: Queue<PlaybackGap> = Queue<PlaybackGap>()
    static var subsequentTrack: IndexedTrack?
    
    static func hasGaps() -> Bool {
        return subsequentTrack != nil && gaps.size() > 0
    }
    
    static func getId() -> Int {
        return id
    }
    
    static func isCurrent(_ contextId: Int) -> Bool {
        return contextId == id
    }
    
    static func getGapLength() -> Double {
        
        var length: Double = 0.0
        let gapsArr = gaps.toArray()
        
        for gap in gapsArr {
            length += gap.duration
        }
        
        return length
    }
    
    static func clear() {
        
        id = -1
        gaps.clear()
        subsequentTrack = nil
    }
    
    private static func initialize() {
        id = Int.random(in: 0...Int.max)
    }
    
    static func addGap(_ gap: PlaybackGap) {
        
        if gaps.size() == 0 {
            initialize()
        }
        
        gaps.enqueue(gap)
    }
    
    static func getGaps() -> [PlaybackGap] {
        return gaps.toArray()
    }
}
