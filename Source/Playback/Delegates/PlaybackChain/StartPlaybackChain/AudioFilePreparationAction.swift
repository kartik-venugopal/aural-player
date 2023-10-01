//
//  AudioFilePreparationAction.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Chain of responsibility action that prepares a track for playback:
///
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
            chain.terminate(context, error as? DisplayableError ?? TrackNotPlayableError(newTrack.file))
        }
    }
}
