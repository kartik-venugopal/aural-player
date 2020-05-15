import Foundation

class AudioFilePreparationAction: NSObject, PlaybackPreparationAction, AsyncMessageSubscriber {
    
    private let player: PlayerProtocol
    private let sequencer: PlaybackSequencerProtocol
    private let transcoder: TranscoderProtocol
    
    var subscriberId: String {
        
        // There may be multiple instances of this class. subscriberId should be unique across instances.
        return String(format: "%@-%d", self.className, self.hashValue)
    }
    
    init(_ player: PlayerProtocol, _ sequencer: PlaybackSequencerProtocol, _ transcoder: TranscoderProtocol) {
        
        self.player = player
        self.sequencer = sequencer
        self.transcoder = transcoder
    }
    
    func execute(_ context: PlaybackRequestContext) -> Bool {
        
        guard let track = context.requestedTrack?.track else {return false}
        
        TrackIO.prepareForPlayback(track)
        
        // Track preparation failed
        if track.lazyLoadingInfo.preparationFailed, let preparationError = track.lazyLoadingInfo.preparationError {
            
            // If an error occurs, end the playback sequence
            sequencer.end()
            
            // Send out an async error message instead of throwing
            AsyncMessenger.publishMessage(TrackNotPlayedAsyncMessage(context.currentTrack, preparationError))
            
            return false
        }
        // Track needs to be transcoded (i.e. audio format is not natively supported)
        else if !track.lazyLoadingInfo.preparedForPlayback && track.lazyLoadingInfo.needsTranscoding {
            
            // Defer playback until transcoding finishes
            transcoder.transcodeImmediately(track)
            
            // Notify the player that transcoding has begun.
            player.transcoding()
            
            return false
        }
        
        return true
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
       
        if let transcodingFinishedMsg = message as? TranscodingFinishedAsyncMessage {
            
            transcodingFinished(transcodingFinishedMsg)
            return
        }
    }
    
    private func transcodingFinished(_ msg: TranscodingFinishedAsyncMessage) {
        
//        if msg.success {
//            
//            
//            
//        } else {
//            
//            stop()
//            
//            // Send out playback error message "transcoding failed"
//            AsyncMessenger.publishMessage(TrackNotTranscodedAsyncMessage(msg.track, msg.track.lazyLoadingInfo.preparationError!))
//        }
    }
}
