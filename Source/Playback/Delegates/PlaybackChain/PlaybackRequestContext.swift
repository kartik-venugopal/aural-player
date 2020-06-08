import Foundation

/*
    Encapsulates request parameters and other information pertinent to the
    execution of a playback request (eg. starting/stopping track playback).
 */
class PlaybackRequestContext {
    
    // The state of the player prior to execution of this reqeust.
    // Current state can change (if waiting or transcoding before playback)
    var currentState: PlaybackState
    
    // The current player track, if any, prior to execution of this reqeust.
    var currentTrack: Track?
    
    // The seek position of the player, if any, prior to execution of this reqeust.
    var currentSeekPosition: Double

    // The track that has been requested for playback. May be nil (e.g. when stopping the player)
    var requestedTrack: Track?
    
    // Playback-related parameters provided prior to execution of this request.
    // Request params may change as the preparation chain executes.
    var requestParams: PlaybackParams
    
    // Keeps track of all individual playback gaps that together determine the delay prior to playback.
    var gaps: [PlaybackGap] = []
    
    // The requested delay before playback (computed as the sum of all playback gap durations)
    var delay: Double? {
        return gaps.count > 0 ? gaps.map {$0.duration}.reduce(0, +) : nil
    }

    init(_ currentState: PlaybackState, _ currentTrack: Track?, _ currentSeekPosition: Double, _ requestedTrack: Track?, _ requestParams: PlaybackParams) {
        
        self.currentState = currentState
        self.currentTrack = currentTrack
        self.currentSeekPosition = currentSeekPosition
        
        self.requestedTrack = requestedTrack
        self.requestParams = requestParams
    }

    // Adds a single playback gap
    func addGap(_ gap: PlaybackGap) {
        
        gaps.append(gap)
        
        // If a non-implicit gap is defined, it invalidates any implicit gaps.
        if gaps.contains(where: {$0.type != .implicit}) {
            gaps.removeAll(where: {$0.type == .implicit})
        }
    }
    
    // Removes all defined playback gaps
    func removeAllGaps() {
        gaps.removeAll()
    }
    
    // TODO: Remove this func after testing
    func toString() -> String {
        return String(describing: JSONMapper.map(self))
    }
    
    // MARK: Static members to keep track of context instances
    
    // Keeps track of the currently executing request context, if any.
    static var currentContext: PlaybackRequestContext?

    // Marks a context as having begun execution.
    static func begun(_ context: PlaybackRequestContext) {
        currentContext = context
    }
    
    // Marks a context as having completed execution.
    static func completed(_ context: PlaybackRequestContext) {
        
        if isCurrent(context) {
            clearCurrentContext()
        }
    }
    
    // Checks if a given context matches the currently executing context.
    static func isCurrent(_ context: PlaybackRequestContext) -> Bool {
        return context === currentContext
    }
    
    // Invalidates the currently executing context.
    static func clearCurrentContext() {
        currentContext = nil
    }
}
