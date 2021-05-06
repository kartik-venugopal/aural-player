import Foundation

/*
    Prepares a track for playback:
    - reading audio metadata
 */
class AudioFilePreparationAction: PlaybackChainAction {
    
    private let trackReader: TrackReader
    
    init(trackReader: TrackReader) {
        self.trackReader = trackReader
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        guard let newTrack = context.requestedTrack else {
            
            chain.terminate(context, NoRequestedTrackError.instance)
            return
        }
        
        do {
            
            try trackReader.prepareForPlayback(track: newTrack)

            // Proceed if not waiting
            chain.proceed(context)
    
        } catch {
            
            NSLog("Unable to prepare track \(newTrack.file.lastPathComponent) for playback: \(error)")
            
            // Track preparation failed, terminate the chain.
            chain.terminate(context, newTrack.preparationError!)
        }
    }
}
