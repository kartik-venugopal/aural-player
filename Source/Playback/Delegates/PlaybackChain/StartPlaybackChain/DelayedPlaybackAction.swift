import Foundation

class DelayedPlaybackAction: PlaybackChainAction {
    
    private let player: PlayerProtocol
    private let sequencer: PlaybackSequencerProtocol
    private let transcoder: TranscoderProtocol
    
    var nextAction: PlaybackChainAction?
    
    init(_ player: PlayerProtocol, _ sequencer: PlaybackSequencerProtocol, _ transcoder: TranscoderProtocol) {
        
        self.player = player
        self.sequencer = sequencer
        self.transcoder = transcoder
    }
    
    func execute(_ context: PlaybackRequestContext) {
        
        guard let newTrack = context.requestedTrack else {return}
        
        if let delay = context.requestParams.delay {
                    
            // Mark the current state as "waiting" in between tracks
            player.waiting()
            
            let gapEndTime_dt = DispatchTime.now() + delay
            let gapEndTime: Date = DateUtils.addToDate(Date(), delay)
            
            DispatchQueue.main.asyncAfter(deadline: gapEndTime_dt) {
                
                // Perform this check to account for the possibility that the gap has been skipped (e.g. user performs Play or Next/Previous track)
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
            }
            
            // Playback chain has ended.
            return
        }
        
        // No delay defined, proceed with chain.
        nextAction?.execute(context)
    }
    
    // Returns whether or not track preparation was successful.
    private func doPrepareTrack(_ newTrack: Track, _ oldTrack: Track?) -> Bool {
        
        TrackIO.prepareForPlayback(newTrack)
        
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
