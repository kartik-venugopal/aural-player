import Foundation

class ValidateNewTrackAction: PlaybackChainAction {
    
    var nextAction: PlaybackChainAction?
    
    // The actual playback sequence
    private let sequencer: PlaybackSequencerProtocol
    
    init(_ sequencer: PlaybackSequencerProtocol) {
        self.sequencer = sequencer
    }
    
    func execute(_ context: PlaybackRequestContext) {
        
        guard let newTrack = context.requestedTrack else {return}
        
        print("\tValidating:", newTrack.conciseDisplayName)
            
        // Validate track before attempting to play it
        if let preparationError = AudioUtils.validateTrack(newTrack) {
        
            // Note any error encountered
            newTrack.lazyLoadingInfo.preparationFailed(preparationError)
            
            // Playback is halted, and the playback sequence is ended.
            sequencer.end()
            
            // Send out an async error message instead of throwing
            AsyncMessenger.publishMessage(TrackNotPlayedAsyncMessage(context.currentTrack, preparationError))
            
            return
            
        } else {
            
            // Track is valid, OK to proceed
            nextAction?.execute(context)
        }
    }
}
