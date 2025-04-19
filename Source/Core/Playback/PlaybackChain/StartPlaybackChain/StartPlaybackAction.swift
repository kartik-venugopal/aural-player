//
//  StartPlaybackAction.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Chain of responsibility action that initiates playback of a requested track.
///
class StartPlaybackAction: PlaybackChainAction {
    
    private let playerPlayFunction: PlayerPlayFunction
    
    init(playerPlayFunction: @escaping PlayerPlayFunction) {
        self.playerPlayFunction = playerPlayFunction
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        // Cannot proceed if no requested track is specified.
        guard let newTrack = context.requestedTrack else {
            
            chain.terminate(context, NoRequestedTrackError.instance)
            return
        }
        
        // Publish a pre-track-change notification for observers who need to perform actions before the track changes.
        // e.g. applying audio settings/effects.
        if context.currentTrack != newTrack {
            Messenger.publish(PreTrackPlaybackNotification(oldTrack: context.currentTrack, oldState: context.currentState, newTrack: newTrack))
        }
        
        // Start playback
        let params = PlaybackParams.defaultParams().withStartAndEndPosition(context.requestParams.startPosition, context.requestParams.endPosition)
        playerPlayFunction(newTrack, params)
        
        // Inform observers of the track change/transition.
        Messenger.publish(TrackTransitionNotification(beginTrack: context.currentTrack, beginState: context.currentState,
                                                      endTrack: context.requestedTrack, endState: .playing))
        
        chain.proceed(context)
    }
}
