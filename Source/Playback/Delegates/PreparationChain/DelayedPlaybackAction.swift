import Foundation

class DelayedPlaybackAction: PlaybackPreparationCompositeAction {
    
    private let player: PlayerProtocol
    private let sequencer: PlaybackSequencerProtocol
    private let transcoder: TranscoderProtocol
    
    var actions: [PlaybackPreparationAction] = []
    
    init(_ player: PlayerProtocol, _ sequencer: PlaybackSequencerProtocol, _ transcoder: TranscoderProtocol) {
        
        self.player = player
        self.sequencer = sequencer
        self.transcoder = transcoder
        
        let clearGapContextAction: ClearGapContextAction = ClearGapContextAction()
        let audioFilePrepAction: AudioFilePreparationAction = AudioFilePreparationAction(player, sequencer, transcoder)
        let playbackAction: PlaybackAction = PlaybackAction(player)
        
        actions = [clearGapContextAction, audioFilePrepAction, playbackAction]
    }
    
    func execute(_ context: PlaybackRequestContext) -> Bool {
        
        guard let newTrack = context.requestedTrack else {return false}
        
        if let delay = context.requestParams.delay {
                    
            let gapContextId = PlaybackGapContext.id
            
            // Mark the current state as "waiting" in between tracks
            player.waiting()
            
            let gapEndTime_dt = DispatchTime.now() + delay
            let gapEndTime: Date = DateUtils.addToDate(Date(), delay)
            
            DispatchQueue.main.asyncAfter(deadline: gapEndTime_dt) {
                
                // Perform this check to account for the possibility that the gap has been skipped (e.g. user performs Play or Next/Previous track)
                if PlaybackGapContext.isCurrent(gapContextId) {

                    // Override the current state of the context, because there was a delay
                    context.currentState = .waiting
                    
                    // Begin playback
                    for action in self.actions {
                        
                        // Execute the action and check if it is ok to proceed.
                        if !action.execute(context) {break}
                    }
                }
            }
            
            // Prepare the track for playback ahead of time (so that the track is ready to play when the gap ends).
            TrackIO.prepareForPlayback(newTrack.track)
            
            // Let observers know that a playback gap has begun
            AsyncMessenger.publishMessage(PlaybackGapStartedAsyncMessage(gapEndTime, context.currentTrack, newTrack))
            
            // Playback chain has ended.
            return false
        }
        
        return true
    }
}
