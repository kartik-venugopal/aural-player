import Foundation

class DelayedPlaybackAction: PlaybackChainAction {
    
    private let player: PlayerProtocol
    private let sequencer: SequencerProtocol
    private let transcoder: TranscoderProtocol
    
    var nextAction: PlaybackChainAction?
    
    init(_ player: PlayerProtocol, _ sequencer: SequencerProtocol, _ transcoder: TranscoderProtocol) {
        
        self.player = player
        self.sequencer = sequencer
        self.transcoder = transcoder
    }
    
    func execute(_ context: PlaybackRequestContext) {
        
        guard let newTrack = context.requestedTrack else {return}
        
        if context.requestParams.allowDelay, let delay = context.delay {
                    
            // Mark the current state as "waiting" in between tracks
            player.waiting()
            
            let gapEndTime_dt = DispatchTime.now() + delay
            let gapEndTime: Date = DateUtils.addToDate(Date(), delay)
            
            DispatchQueue.main.asyncAfter(deadline: gapEndTime_dt) {
                
                // Perform this check to account for the possibility that the gap has been skipped (e.g. user performs Play or Next/Previous track or Stop)
                if PlaybackRequestContext.isCurrent(context) {

                    // Override the current state of the context, because there was a delay
                    context.currentState = .waiting
                    
                    // Continue the playback chain
                    self.nextAction?.execute(context)
                }
            }
            
            // Prepare the track for playback ahead of time (so that the track is ready to play when the gap ends).
            if doPrepareTrack(newTrack, context.currentTrack) {
            
                // Let observers know that a playback gap has begun
                AsyncMessenger.publishMessage(PlaybackGapStartedAsyncMessage(gapEndTime, context.currentTrack, newTrack))
                
            } else {
                
                // Some error occurred during track preparation. Terminate the chain.
                PlaybackRequestContext.completed(context)
            }
            
            // Playback chain has been deferred for later.
            return
        }
        
        // No delay defined, proceed with chain.
        nextAction?.execute(context)
    }
    
    // Returns whether or not track preparation was successful.
    private func doPrepareTrack(_ newTrack: Track, _ oldTrack: Track?) -> Bool {
        
        newTrack.prepareForPlayback()
        
        // Track preparation failed
        if newTrack.lazyLoadingInfo.preparationFailed, let preparationError = newTrack.lazyLoadingInfo.preparationError {
            
            // If an error occurs, end the playback sequence
            sequencer.end()
            
            // Send out an async error message instead of throwing
            AsyncMessenger.publishMessage(TrackNotPlayedAsyncMessage(oldTrack, preparationError))
            
            return false
        }
        // Track needs to be transcoded (i.e. audio format is not natively supported)
        else if !newTrack.lazyLoadingInfo.preparedForPlayback && newTrack.lazyLoadingInfo.needsTranscoding {
            
            transcoder.transcodeImmediately(newTrack)
        }
        
        return true
    }
}
