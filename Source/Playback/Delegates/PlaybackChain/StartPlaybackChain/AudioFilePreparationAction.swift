import Foundation

class AudioFilePreparationAction: NSObject, PlaybackChainAction {
    
    private let player: PlayerProtocol
    private let transcoder: TranscoderProtocol
    
    init(_ player: PlayerProtocol, _ transcoder: TranscoderProtocol) {
        
        self.player = player
        self.transcoder = transcoder

        super.init()
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        guard let newTrack = context.requestedTrack else {
            
            chain.terminate(context, InvalidTrackError.noRequestedTrack)
            return
        }
        
        let isWaiting: Bool = checkForDelayAndDefer(newTrack, context, chain)
        prepareTrackAndProceed(newTrack, context, chain, isWaiting)
    }
    
    func checkForDelayAndDefer(_ newTrack: Track, _ context: PlaybackRequestContext, _ chain: PlaybackChain) -> Bool {
        
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
                    
                    // Need to call prepare again to ensure that preparation is completed before playback
                    self.prepareTrackAndProceed(newTrack, context, chain, false)
                }
            }
            
            // Let observers know that a playback gap has begun
            AsyncMessenger.publishMessage(PlaybackGapStartedAsyncMessage(gapEndTime, context.currentTrack, newTrack))
            
            return true
        }
        
        return false
    }
    
    func prepareTrackAndProceed(_ track: Track, _ context: PlaybackRequestContext, _ chain: PlaybackChain, _ isWaiting: Bool) {
        
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
            transcoder.transcodeImmediately(track)
            
            // Notify the player that transcoding has begun, and defer playback.
            // NOTE - The waiting state takes precedence over the transcoding state.
            // If a track is both waiting and transcoding, its state will be waiting.
            if !isWaiting {
                player.transcoding()
            }
            
            return
        }
        
        // Proceed if not waiting
        if !isWaiting {
            chain.proceed(context)
        }
    }
}
