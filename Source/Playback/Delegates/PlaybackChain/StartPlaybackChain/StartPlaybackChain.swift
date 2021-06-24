//
//  StartPlaybackChain.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

/*
    A PlaybackChain that starts playback of a specific track.
    It is composed of several actions that perform any required
    pre-processing or notifications.
 */
class StartPlaybackChain: PlaybackChain, NotificationSubscriber {

    private let player: PlayerProtocol
    private let sequencer: SequencerProtocol
    
    init(_ player: PlayerProtocol, _ sequencer: SequencerProtocol, _ playlist: PlaylistCRUDProtocol, trackReader: TrackReader, _ profiles: PlaybackProfiles, _ preferences: PlaybackPreferences) {
        
        self.player = player
        self.sequencer = sequencer
        super.init()
        
        _ = self.withAction(SavePlaybackProfileAction(profiles, preferences))
        .withAction(HaltPlaybackAction(player))
        .withAction(AudioFilePreparationAction(trackReader: trackReader))
        .withAction(ApplyPlaybackProfileAction(profiles, preferences))
        .withAction(StartPlaybackAction(player))
        .withAction(PredictiveTrackPreparationAction(sequencer: sequencer, trackReader: trackReader))
    }
    
    override func execute(_ context: PlaybackRequestContext) {
        
        actionIndex = -1
        PlaybackRequestContext.begun(context)
        
        Messenger.publish(.player_preTrackChange)
        proceed(context)
    }
    
    // Halts playback and ends the playback sequence when an error is encountered.
    override func terminate(_ context: PlaybackRequestContext, _ error: DisplayableError) {

        player.stop()
        sequencer.end()
        
        if let errorTrack = context.requestedTrack {
            
            // Notify observers of the error, and complete the request context.
            Messenger.publish(TrackNotPlayedNotification(oldTrack: context.currentTrack, errorTrack: errorTrack, error: error))
        }
        
        complete(context)
    }
}
