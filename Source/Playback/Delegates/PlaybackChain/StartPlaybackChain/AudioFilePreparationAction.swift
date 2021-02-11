import Foundation

/*
    Prepares a track for playback:

    - delay (if defined in the request)
    - transcoding (if required)
    - reading audio metadata
 */
class AudioFilePreparationAction: PlaybackChainAction {
    
    private let player: PlayerProtocol
    private let transcoder: TranscoderProtocol
    
    init(_ player: PlayerProtocol, _ transcoder: TranscoderProtocol) {
        
        self.player = player
        self.transcoder = transcoder
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        guard let newTrack = context.requestedTrack else {
            
            chain.terminate(context, InvalidTrackError.noRequestedTrack)
            return
        }
        
        prepareTrackAndProceed(newTrack, context, chain)
    }
    
    func prepareTrackAndProceed(_ track: Track, _ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        track.prepareForPlayback()
        
        // Track preparation failed, terminate the chain.
        if track.lazyLoadingInfo.preparationFailed, let preparationError = track.lazyLoadingInfo.preparationError {
            
            chain.terminate(context, preparationError)
            return
        }
        
        // Track needs to be transcoded (i.e. audio format is not natively supported)
        if !track.lazyLoadingInfo.preparedForPlayback && track.lazyLoadingInfo.needsTranscoding {
            
            // Start transcoding the track
            // NOTE - Transcoding for this track may have already begun (triggered during a delay).
            let transcodeResult = transcoder.transcodeImmediately(track)
            
            if transcodeResult.transcodingFailed, let error = track.lazyLoadingInfo.preparationError {
                
                chain.terminate(context, error)
                return
            }
            
            if !transcodeResult.readyForPlayback {
            
                // Notify the player that transcoding has begun, and defer playback.
                transitionToTranscodingState(context)
                return
            }
        }
        
        // Proceed
        chain.proceed(context)
    }
    
    private func transitionToTranscodingState(_ context: PlaybackRequestContext) {
        
        // Mark the current state as "transcoding" the requested track, and notify observers.
        player.transcoding()
        Messenger.publish(TrackTransitionNotification(beginTrack: context.currentTrack, beginState: context.currentState,
                                                      endTrack: context.requestedTrack, endState: .transcoding))
        
        // Update the context to reflect this transition
        context.currentTrack = context.requestedTrack
        context.currentState = .transcoding
        context.currentSeekPosition = 0
    }
}
