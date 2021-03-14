import Foundation

/*
    Prepares a track for playback:
    - reading audio metadata
 */
class AudioFilePreparationAction: PlaybackChainAction {
    
    private let player: PlayerProtocol
    private let trackReader: TrackReader
    
    init(player: PlayerProtocol, trackReader: TrackReader) {
        
        self.player = player
        self.trackReader = trackReader
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        guard let newTrack = context.requestedTrack else {
            
            chain.terminate(context, NoRequestedTrackError.instance)
            return
        }
        
        prepareTrackAndProceed(newTrack, context, chain)
    }
    
    func prepareTrackAndProceed(_ track: Track, _ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        do {
            
            try trackReader.prepareForPlayback(track: track)

            // Proceed if not waiting
            chain.proceed(context)
    
        } catch {
            
            print("\nCouldn't prepare track \(track.file.lastPathComponent) for playback: \(error)")
            
            // Track preparation failed, terminate the chain.
            chain.terminate(context, track.preparationError!)
        }
    }
}
