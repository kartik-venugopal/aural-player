import Foundation

class ValidateNewTrackAction: PlaybackChainAction {
    
    var nextAction: PlaybackChainAction?
    
    // The actual playback sequence
    private let sequencer: SequencerProtocol
    
    init(_ sequencer: SequencerProtocol) {
        self.sequencer = sequencer
    }
    
    func execute(_ context: PlaybackRequestContext) {
        
        guard let newTrack = context.requestedTrack else {return}
        
        // Validate track before attempting to play it
        if let preparationError = newTrack.validateAudio() {
        
            // Note any error encountered
            newTrack.lazyLoadingInfo.preparationFailed(preparationError)
            
            // Playback is halted, and the playback sequence is ended.
            sequencer.end()
            
            // Send out an async error message instead of throwing
            AsyncMessenger.publishMessage(TrackNotPlayedAsyncMessage(context.currentTrack, preparationError))
            
            // Terminate the chain
            PlaybackRequestContext.completed(context)
            
            return
            
        } else {
            
            // Track is valid, OK to proceed
            nextAction?.execute(context)
        }
    }
}
