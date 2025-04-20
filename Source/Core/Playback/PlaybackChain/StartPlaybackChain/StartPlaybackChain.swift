//
//  StartPlaybackChain.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A chain of responsibility that initiates playback of a specific track.
/// 
/// It is composed of several actions that perform any required
/// pre-processing or notifications.
///
class StartPlaybackChain: PlaybackChain {

    private let playerPlayFunction: PlayerPlayFunction
    private let playerStopFunction: PlayerStopFunction
    private let playQueue: PlayQueueProtocol
    
    init(playerPlayFunction: @escaping PlayerPlayFunction,
         playerStopFunction: @escaping PlayerStopFunction,
         playQueue: PlayQueueProtocol,
         trackReader: TrackReader,
         _ preferences: PlaybackPreferences) {
        
        self.playerPlayFunction = playerPlayFunction
        self.playerStopFunction = playerStopFunction
        self.playQueue = playQueue
        super.init()
        
        _ = self.withAction(SavePlaybackProfileAction(preferences: preferences))
        .withAction(LastFMScrobbleAction())
        .withAction(HaltPlaybackAction(playerStopFunction: playerStopFunction))
        .withAction(AudioFilePreparationAction(trackReader: trackReader))
        .withAction(ApplyPlaybackProfileAction(preferences: preferences))
        .withAction(StartPlaybackAction(playerPlayFunction: playerPlayFunction))
        .withAction(PredictiveTrackPreparationAction(playQueue: playQueue, trackReader: trackReader))
        
        // TODO: Add an UpdateHistoryAction !!!
    }
    
    override func execute(_ context: PlaybackRequestContext) {
        
        actionIndex = -1
        PlaybackRequestContext.begun(context)
        
        Messenger.publish(.Player.preTrackChange)
        proceed(context)
    }
    
    // Halts playback and ends the playback sequence when an error is encountered.
    override func terminate(_ context: PlaybackRequestContext, _ error: DisplayableError) {

        player.stop()
        playQueue.stop()
        
        if let errorTrack = context.requestedTrack {
            
            // Notify observers of the error, and complete the request context.
            Messenger.publish(TrackNotPlayedNotification(oldTrack: context.currentTrack, errorTrack: errorTrack, error: error))
        }
        
        complete(context)
    }
}
