import Foundation

///
/// Tries to predict which track might play next, and prepares all those candidate tracks ahead of time,
/// in anticipation of their playback.
 
/// The advantage of doing this is that when one of those tracks is actually selected for playback,
/// there will be no time required to prep it for playback since this has already been done, and
/// the user-audible gap between tracks will be greatly reduced.
///
class PredictiveTrackPreparationAction: PlaybackChainAction {
    
    private let sequencer: SequencerProtocol
    private let trackReader: TrackReader
    
    init(sequencer: SequencerProtocol, trackReader: TrackReader) {
        
        self.sequencer = sequencer
        self.trackReader = trackReader
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        // Perform this task async, since it is not required to complete immediately.
        // Since this task is not time-critical, it is okay to use the "utility" quality of service.
        DispatchQueue.global(qos: .utility).async {
    
            // The candidates for which track might play next consist of:
            //
            // 1 - The "subsequent" track in the playback sequence, i.e. the track that would play next automatically.
            // 2 - The "next" track which would play if the user triggered the "Next track" function.
            // 3 - The "previous" track which would play if the user triggered the "Previous track" function.
            let nillableTracksArray: [Track?] = [self.sequencer.peekSubsequent(), self.sequencer.peekNext(), self.sequencer.peekPrevious()]
            
            // Since some of the candidate tracks might be the same track (subsequent track might be the same as the next track), we need
            // to put them in a Set, and also eliminate nil values.
            let predictedNextTracks: Set<Track> = Set(nillableTracksArray.compactMap{$0})
            
            // Prepare each of the candidate tracks for playback.
            predictedNextTracks.forEach {
                
                NSLog("\nPreparing \($0.displayName) for playback ...")
                
                do {
                    try self.trackReader.prepareForPlayback(track: $0)
                } catch {}
            }
        }
        
        // Mark the playback chain as having completed execution.
        chain.complete(context)
    }
}
