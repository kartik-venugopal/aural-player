import Foundation

class PlaybackGap {
    
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

extension PlaybackGap: Hashable {
    
    static func == (lhs: PlaybackGap, rhs: PlaybackGap) -> Bool {
        return (lhs.id == rhs.id)
    }
    
    /**var hashValue: Int {
        return self.id
    }**/
    
    func hash(into hasher: inout Hasher) {
        // The file path of the track is the unique identifier
        return hasher.combine(self.id)
        
    }
}

class PlaybackGapContext {
    
    private static var id: Int = -1
    private static var gaps: [PlaybackGap: IndexedTrack] = [:]
    
    static func hasGaps() -> Bool {
        return !gaps.isEmpty
    }
    
    static func getId() -> Int {
        return id
    }
    
    static func isCurrent(_ contextId: Int) -> Bool {
        return contextId == id
    }
    
    static func getGapLength() -> Double {
        
        var length: Double = 0.0
        for gap in gaps.keys {
            length += gap.duration
        }
        
        return length
    }
    
    static func removeImplicitGap() {
        
        if !gaps.isEmpty {
        
            for gap in gaps.keys {
                
                if gap.type == .implicit {
                    gaps.removeValue(forKey: gap)
                    return
                }
            }
        }
    }
    
    static func oneTimeGaps() -> [PlaybackGap: IndexedTrack] {
        return gaps.filter({$0.key.type == .oneTime})
    }
    
    static func gapBeforeNextTrack() -> PlaybackGap? {
        
        for gap in gaps {
            
            if gap.key.position == .beforeTrack {
                return gap.key
            }
        }
        
        return nil
    }
    
    static func gapAfterLastTrack() -> PlaybackGap? {
        
        for gap in gaps {
            
            if gap.key.position == .afterTrack {
                return gap.key
            }
        }
        
        return nil
    }
    
    static func clear() {
        
        id = -1
        gaps.removeAll()
    }
    
    private static func initialize() {
        id = Int.random(in: 0...Int.max)
    }
    
    static func addGap(_ gap: PlaybackGap, _ track: IndexedTrack) {
        
        if gaps.isEmpty {
            initialize()
        }
        
        gaps[gap] = track
    }
}
