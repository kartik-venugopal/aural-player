import Foundation

class TrackChangeContext {
    
    // This is the state prior to track change
    static var currentTrack: IndexedTrack?
    static var currentState: PlaybackState = .noTrack
    
    static var newTrack: IndexedTrack?
    
    static func setCurrentState(_ curTrack: IndexedTrack?, _ curState: PlaybackState) {
        
        currentTrack = curTrack
        currentState = curState
    }
    
    static func setNewTrack(_ track: IndexedTrack?) {
        
        newTrack = track
    }
    
    static func encapsulate() -> TrackChangedAsyncMessage {
        return TrackChangedAsyncMessage(currentTrack, currentState, newTrack)
    }
}

class PlaybackParams {
    
    var allowDelay: Bool = true     // This flag applies to gaps as well. A false value indicates immediate playback.
    var delay: Double? = nil
    
    var startPosition: Double? = nil
    var endPosition: Double? = nil
    
    var interruptPlayback: Bool = true
    
    func withDelay(_ delay: Double?) -> PlaybackParams {
        self.delay = delay
        return self
    }
    
    func withStartPosition(_ startPosition: Double?) -> PlaybackParams {
        self.startPosition = startPosition
        return self
    }
    
    func withStartAndEndPosition(_ startPosition: Double?, _ endPosition: Double?) -> PlaybackParams {
        self.startPosition = startPosition
        self.endPosition = endPosition
        return self
    }
    
    func withAllowDelay(_ allowDelay: Bool) -> PlaybackParams {
        self.allowDelay = allowDelay
        return self
    }
    
    func withInterruptPlayback(_ interruptPlayback: Bool) -> PlaybackParams {
        self.interruptPlayback = interruptPlayback
        return self
    }
    
    static func defaultParams() -> PlaybackParams {
        return PlaybackParams()
    }
}
