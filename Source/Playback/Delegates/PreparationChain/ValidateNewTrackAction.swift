import Foundation

class ValidateNewTrackAction: PlaybackPreparationAction {
    
    // The actual playback sequence
    private let sequencer: PlaybackSequencerProtocol
    
    init(_ sequencer: PlaybackSequencerProtocol) {
        self.sequencer = sequencer
    }
    
    func execute(_ context: PlaybackRequestContext) -> Bool {
        
        guard let newTrack = context.requestedTrack else {return true}
            
        // Validate track before attempting to play it
        if let preparationError = AudioUtils.validateTrack(newTrack.track) {
        
            // Note any error encountered
            newTrack.track.lazyLoadingInfo.preparationFailed(preparationError)
            
            // Playback is halted, and the playback sequence is ended.
            sequencer.end()
            
            // Send out an async error message instead of throwing
            AsyncMessenger.publishMessage(TrackNotPlayedAsyncMessage(context.currentTrack, preparationError))
            
            return false
            
        } else {
            
            // Track is valid, OK to proceed
            return true
        }
    }
}
