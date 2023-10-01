//
//  PredictiveTrackPreparationAction.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Chain of responsibility action that tries to predict which track might play next, and prepares all
/// those candidate tracks ahead of time, in anticipation of their playback.
 
/// The advantage of doing this is that when one of those tracks is actually selected for playback,
/// there will be no time required to prep it for playback since this has already been done, and
/// the user-audible gap between tracks will be reduced.
///
class PredictiveTrackPreparationAction: PlaybackChainAction {
    
    private let sequencer: SequencerProtocol
    private let trackReader: TrackReader
    
    ///
    /// Keeps a record of all tracks that have been prepped for playback.
    /// Is useful when closing files that no longer need to be open.
    ///
    private var preppedTracks: Set<Track> = Set()
    
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
            let nillableTracksArray: [Track?] = [self.sequencer.peekSubsequent(), self.sequencer.peekNext()]
            
            // Since some of the candidate tracks might be the same track (subsequent track might be the same as the next track), we need
            // to put them in a Set, and also eliminate nil values.
            let predictedNextTracks: Set<Track> = Set(nillableTracksArray.compactMap{$0}.filter {$0 != context.requestedTrack})
            
            // Prepare each of the candidate tracks for playback.
            predictedNextTracks.forEach {
                
                do {
                    try self.trackReader.prepareForPlayback(track: $0, immediate: false)
                } catch {}
            }
            
            // Update the preppedTracks set and close files that no longer need to be open (i.e. not
            // currently playing and not predicted to play next).
            
            let playingTrack: Track? = context.requestedTrack
            let tracksToClose: [Track] = self.preppedTracks.filter {$0 != playingTrack && !predictedNextTracks.contains($0)}
            
            for track in tracksToClose {
                
                track.playbackContext?.close()
                self.preppedTracks.remove(track)
            }
            
            // Add the candidate tracks to the preppedTracks set.
            self.preppedTracks = self.preppedTracks.union(predictedNextTracks)
        }
            
        chain.proceed(context)
    }
}
