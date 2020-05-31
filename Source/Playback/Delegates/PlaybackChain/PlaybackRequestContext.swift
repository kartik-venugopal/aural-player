import Foundation

class PlaybackRequestContext {
    
    // Current state can change (if waiting or transcoding before playback)
    var currentState: PlaybackState
    
    let currentTrack: Track?
    let currentSeekPosition: Double

    var requestedTrack: Track?
    var cancelTranscoding: Bool
    
    // Request params may change as the preparation chain executes.
    var requestParams: PlaybackParams
    
    var delay: Double?
    
    var transcodingBegun: Bool = false

    private init(_ currentState: PlaybackState, _ currentTrack: Track?, _ currentSeekPosition: Double, _ requestedTrack: Track?, _ cancelTranscoding: Bool, _ requestParams: PlaybackParams) {
        
        self.currentState = currentState
        self.currentTrack = currentTrack
        self.currentSeekPosition = currentSeekPosition
        
        self.requestedTrack = requestedTrack
        self.cancelTranscoding = cancelTranscoding
        self.requestParams = requestParams
    }
    
    func begun() {
        PlaybackRequestContext.begun(self)
    }
    
    func completed() {
        PlaybackRequestContext.completed(self)
    }
    
    func setDelay(_ newDelay: Double) {
        delay = newDelay
    }
    
    func addDelay(_ newDelay: Double) {
        
        if let theDelay = delay {
            delay = theDelay + newDelay
        } else {
            delay = newDelay
        }
    }
    
    func toString() -> String {
        return String(describing: JSONMapper.map(self))
    }
    
    // MARK: Static members to keep track of context instances
    
    static var currentContext: PlaybackRequestContext?
    
    static func create(_ currentState: PlaybackState, _ currentTrack: Track?, _ currentSeekPosition: Double, _ requestedTrack: Track?, _ cancelTranscoding: Bool, _ requestParams: PlaybackParams) -> PlaybackRequestContext {
        
        return PlaybackRequestContext(currentState, currentTrack, currentSeekPosition, requestedTrack, cancelTranscoding, requestParams)
    }
    
    static func begun(_ context: PlaybackRequestContext) {
        currentContext = context
    }
    
    static func completed(_ context: PlaybackRequestContext) {
        
        if isCurrent(context) {
            clearCurrentContext()
        }
    }
    
    static func isCurrent(_ context: PlaybackRequestContext) -> Bool {
        return context === currentContext
    }
    
    static func clearCurrentContext() {
        currentContext = nil
    }
}
