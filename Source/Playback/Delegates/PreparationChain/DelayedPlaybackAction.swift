import Foundation

class DelayedPlaybackAction: PlaybackChainAction {
    
    private let player: PlayerProtocol
    private let sequencer: PlaybackSequencerProtocol
    private let transcoder: TranscoderProtocol
    
//    var actions: [PlaybackPreparationAction] = []
    
    var nextAction: PlaybackChainAction?
    
    init(_ player: PlayerProtocol, _ sequencer: PlaybackSequencerProtocol, _ transcoder: TranscoderProtocol) {
        
        self.player = player
        self.sequencer = sequencer
        self.transcoder = transcoder
        
//        let clearGapContextAction: ClearGapContextAction = ClearGapContextAction()
//        let audioFilePrepAction: AudioFilePreparationAction = AudioFilePreparationAction(player, sequencer, transcoder)
//        let playbackAction: PlaybackAction = PlaybackAction(player)
//
//        actions = [clearGapContextAction, audioFilePrepAction, playbackAction]
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
                    
                    self.nextAction?.execute(context)
                    
                    // Begin playback
//                    for action in self.actions {
//
//                        // Execute the action and check if it is ok to proceed.
//                        if !action.execute(context) {break}
//                    }
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
    private func doPrepareTrack(_ newTrack: IndexedTrack, _ oldTrack: IndexedTrack?) -> Bool {
        
        let track = newTrack.track
        
        TrackIO.prepareForPlayback(track)
        
        // Track preparation failed
        if track.lazyLoadingInfo.preparationFailed, let preparationError = track.lazyLoadingInfo.preparationError {
            
            // If an error occurs, end the playback sequence
            sequencer.end()
            
            // Send out an async error message instead of throwing
            AsyncMessenger.publishMessage(TrackNotPlayedAsyncMessage(oldTrack, preparationError))
            
            return false
        }
        // Track needs to be transcoded (i.e. audio format is not natively supported)
        else if !track.lazyLoadingInfo.preparedForPlayback && track.lazyLoadingInfo.needsTranscoding {
            
            transcoder.transcodeImmediately(track)
        }
        
        return true
    }
}
