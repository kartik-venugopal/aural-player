import Foundation

class PlaybackGap {
    
    // For identity when hashing
    let id: Int
    
    var duration: Double
    var position: PlaybackGapPosition
    var type: PlaybackGapType
    
    convenience init(_ duration: Double, _ position: PlaybackGapPosition) {
        self.init(duration, position, .tillAppExits)
    }
    
    init(_ duration: Double, _ position: PlaybackGapPosition, _ type: PlaybackGapType) {
        
        self.id = Int.random(in: 0 ... Int.max)
        
        self.duration = duration
        self.position = position
        self.type = type
    }
}

enum PlaybackGapPosition {
    
    case beforeTrack
    case afterTrack
}

enum PlaybackGapType {
    
    // Explicit gap types as defined by the user per-track (i.e. applies to a single playlist track)
    case oneTime
    case tillAppExits
    case persistent
    
    // Implicit gap as specified by Playback preferences (i.e. applies to all playlist tracks)
    case implicit
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
    private static var gaps: [PlaybackGap] = []
    static var subsequentTrack: IndexedTrack?
    
    static func hasGaps() -> Bool {
        return subsequentTrack != nil && !gaps.isEmpty
    }
    
    static func getId() -> Int {
        return id
    }
    
    static func isCurrent(_ contextId: Int) -> Bool {
        return contextId == id
    }
    
    static func getGapLength() -> Double {
        
        var length: Double = 0.0
        for gap in gaps {
            length += gap.duration
        }
        
        return length
    }
    
    static func removeImplicitGap() {
        
        if !gaps.isEmpty {
        
            for index in 0..<gaps.count {
                
                let gap = gaps[index]
                
                if gap.type == .implicit {
                    
                    gaps.remove(at: index)
                    
                    // There can only be one implict gap, so it is safe to return once it has been removed
                    return
                }
            }
        }
    }
    
    static func clear() {
        
        id = -1
        gaps.removeAll()
        subsequentTrack = nil
    }
    
    private static func initialize() {
        id = Int.random(in: 0...Int.max)
    }
    
    static func addGap(_ gap: PlaybackGap) {
        
        if gaps.isEmpty {
            initialize()
        }
        
        gaps.append(gap)
    }
    
    static func getGaps() -> [PlaybackGap] {
        let copy = gaps
        return copy
    }
}
