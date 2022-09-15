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

///
/// A chain of responsibility that initiates the stopping of playback of the currently playing track.
///
/// It is composed of several actions that perform any required
/// pre / post-processing or notifications.
///
class StopPlaybackChain: PlaybackChain {
    
    init(_ player: PlayerProtocol, _ playlist: PlaylistAccessorProtocol, _ sequencer: SequencerProtocol, _ profiles: PlaybackProfiles,
         _ preferences: PlaybackPreferences) {
        
        super.init()
        
        _ = self.withAction(SavePlaybackProfileAction(profiles, preferences))
            .withAction(MarkLastPlaybackPositionAction())
            .withAction(HaltPlaybackAction(player))
            .withAction(EndPlaybackSequenceAction(sequencer))
            .withAction(CloseFileHandlesAction(playlist: playlist))
    }
}
