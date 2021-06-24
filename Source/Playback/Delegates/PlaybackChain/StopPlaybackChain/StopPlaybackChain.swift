//
//  StopPlaybackChain.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

/*
    A playback chain specifically for stopping playback.
 */
class StopPlaybackChain: PlaybackChain {
    
    init(_ player: PlayerProtocol, _ playlist: PlaylistAccessorProtocol, _ sequencer: SequencerProtocol, _ profiles: PlaybackProfiles, _ preferences: PlaybackPreferences) {
        
        super.init()
        
        _ = self.withAction(SavePlaybackProfileAction(profiles, preferences))
        .withAction(HaltPlaybackAction(player))
        .withAction(EndPlaybackSequenceAction(sequencer))
        .withAction(CloseFileHandlesAction(playlist: playlist))
    }
}
