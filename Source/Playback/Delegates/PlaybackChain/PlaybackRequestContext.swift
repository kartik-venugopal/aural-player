import Foundation

class PlaybackRequestContext {
    
    // Current state can change (if waiting or transcoding before playback)
    var currentState: PlaybackState
    
    let currentTrack: Track?
    let currentSeekPosition: Double

    var requestedTrack: Track?
    
    // Request params may change as the preparation chain executes.
    var requestParams: PlaybackParams
    
    var gaps: [PlaybackGap] = []
    
    var delay: Double? {
        return gaps.count > 0 ? gaps.map {$0.duration}.reduce(0, +) : nil
    }
    
    var transcodingBegun: Bool = false

    init(_ currentState: PlaybackState, _ currentTrack: Track?, _ currentSeekPosition: Double, _ requestedTrack: Track?, _ requestParams: PlaybackParams) {
        
        self.currentState = currentState
        self.currentTrack = currentTrack
        self.currentSeekPosition = currentSeekPosition
        
        self.requestedTrack = requestedTrack
        self.requestParams = requestParams
    }
    
    func addGap(_ gap: PlaybackGap) {
        
        gaps.append(gap)
        
        // If a non-implicit gap is defined, it invalidates any implicit gaps.
        if gaps.contains(where: {$0.type != .implicit}) {
            gaps.removeAll(where: {$0.type == .implicit})
        }
    }
    
    // TODO: Remove this func after testing
    func toString() -> String {
        return String(describing: JSONMapper.map(self))
    }
    
    // MARK: Static members to keep track of context instances
    
    static var currentContext: PlaybackRequestContext?

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
