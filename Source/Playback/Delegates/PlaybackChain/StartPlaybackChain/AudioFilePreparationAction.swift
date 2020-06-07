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
        
        let delayInfo = checkForDelayAndDefer(newTrack, context, chain)
        prepareTrackAndProceed(newTrack, context, chain, delayInfo.isWaiting, delayInfo.gapEndTime)
    }
    
    func checkForDelayAndDefer(_ newTrack: Track, _ context: PlaybackRequestContext, _ chain: PlaybackChain) -> (isWaiting: Bool, gapEndTime: Date?) {
        
        if context.requestParams.allowDelay, let delay = context.delay {
            
            let gapEndTime_dt: DispatchTime = .now() + delay
            let gapEndTime: Date = Date() + delay
            
            // Continue playback after delay
            DispatchQueue.main.asyncAfter(deadline: gapEndTime_dt, qos: .userInteractive) {
                
                // Perform this check to account for the possibility that the gap has been skipped
                // (e.g. user performs Play or Next/Previous track or Stop)
                if PlaybackRequestContext.isCurrent(context) {
                    
                    // Proceed with playback
                    // Need to call prepare again to ensure that preparation is completed before playback
                    // (It may not have completed when prepare() was called previously, before the gap completed
                    // ... esp. if the gap was very short)
                    self.prepareTrackAndProceed(newTrack, context, chain, false, nil)
                }
            }
            
            return (true, gapEndTime)
        }
        
        return (false, nil)
    }
    
    func prepareTrackAndProceed(_ track: Track, _ context: PlaybackRequestContext, _ chain: PlaybackChain, _ isWaiting: Bool, _ gapEndTime: Date?) {
        
        track.prepareForPlayback()
        
        // Track preparation failed, terminate the chain.
        if track.lazyLoadingInfo.preparationFailed, let preparationError = track.lazyLoadingInfo.preparationError {
            
            chain.terminate(context, preparationError)
            return
        }
        
        if isWaiting, let theGapEndTime = gapEndTime {
            transitionToWaitingState(context, theGapEndTime)
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
                transitionToTranscodingState(context)
            }
            
            return
        }
        
        // Proceed if not waiting
        if !isWaiting {
            chain.proceed(context)
        }
    }
    
    private func transitionToWaitingState(_ context: PlaybackRequestContext, _ gapEndTime: Date) {
        
        // Mark the current state as "waiting" before the requested track
        player.waiting()
        AsyncMessenger.publishMessage(TrackTransitionAsyncMessage(context.currentTrack, context.currentState, context.requestedTrack, .waiting, gapEndTime))
        
        // Update the context to reflect this transition
        context.currentTrack = context.requestedTrack
        context.currentState = .waiting
        context.currentSeekPosition = 0
    }
    
    private func transitionToTranscodingState(_ context: PlaybackRequestContext) {
        
        // Mark the current state as "transcoding" the requested track
        player.transcoding()
        AsyncMessenger.publishMessage(TrackTransitionAsyncMessage(context.currentTrack, context.currentState, context.requestedTrack, .transcoding))
        
        // Update the context to reflect this transition
        context.currentTrack = context.requestedTrack
        context.currentState = .transcoding
        context.currentSeekPosition = 0
    }
}
