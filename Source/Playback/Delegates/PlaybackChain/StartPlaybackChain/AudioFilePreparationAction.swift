import Foundation

class AudioFilePreparationAction: NSObject, PlaybackChainAction, AsyncMessageSubscriber {
    
    private let player: PlayerProtocol
    private let sequencer: SequencerProtocol
    private let transcoder: TranscoderProtocol
    
    var nextAction: PlaybackChainAction?
    
    init(_ player: PlayerProtocol, _ sequencer: SequencerProtocol, _ transcoder: TranscoderProtocol) {
        
        self.player = player
        self.sequencer = sequencer
        self.transcoder = transcoder

        super.init()
        AsyncMessenger.subscribe([.transcodingFinished], subscriber: self, dispatchQueue: DispatchQueue.main)
    }
    
    func execute(_ context: PlaybackRequestContext) {
        
        guard let track = context.requestedTrack else {return}
        
        track.prepareForPlayback()
        
        // Track preparation failed
        if track.lazyLoadingInfo.preparationFailed, let preparationError = track.lazyLoadingInfo.preparationError {
            
            // If an error occurs, end the playback sequence
            sequencer.end()
            
            // Send out an async error message instead of throwing
            AsyncMessenger.publishMessage(TrackNotPlayedAsyncMessage(context.currentTrack, preparationError))
            
            // Terminate the chain
            context.completed()
            
            return
        }
        // Track needs to be transcoded (i.e. audio format is not natively supported)
        else if !track.lazyLoadingInfo.preparedForPlayback && track.lazyLoadingInfo.needsTranscoding {
            
            // Start transcoding the track and defer playback until transcoding finishes
            // NOTE - Transcoding for this track may have already begun (triggered by a previous action).
            transcoder.transcodeImmediately(track)
            
            // Notify the player that transcoding has begun.
            player.transcoding()
            
            // , and suspend the chain for now.
            return
        }
        
        nextAction?.execute(context)
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
       
        if let transcodingFinishedMsg = message as? TranscodingFinishedAsyncMessage {
            
            transcodingFinished(transcodingFinishedMsg)
            return
        }
    }
    
    private func transcodingFinished(_ msg: TranscodingFinishedAsyncMessage) {
        
        // Make sure there is no delay (i.e. state != waiting) before acting on this message.
        // And match the transcoded track to that from the deferred request context.
        if player.state != .waiting, msg.success,
            let currentContext = PlaybackRequestContext.currentContext, msg.track == currentContext.requestedTrack {
            
            NSLog("Proceeding with playback for: %@", msg.track.conciseDisplayName)

            // Proceed with the playback chain.
            nextAction?.execute(currentContext)
        }
    }
}
