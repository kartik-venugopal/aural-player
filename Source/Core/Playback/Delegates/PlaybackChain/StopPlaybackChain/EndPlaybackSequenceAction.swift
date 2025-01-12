//
//  EndPlaybackSequenceAction.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Chain of responsibility action that ends the sequencer's playback sequence
/// and notifies observers of the track change.
///
class EndPlaybackSequenceAction: PlaybackChainAction {
    
    private lazy var messenger = Messenger(for: self)
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        messenger.publish(PreTrackPlaybackNotification(oldTrack: context.currentTrack, oldState: context.currentState, newTrack: nil))
        
        if context.sequenceEnded {
            playQueueDelegate.sequenceEnded()
        } else{
            playQueueDelegate.stop()
        }
        
        messenger.publish(TrackTransitionNotification(beginTrack: context.currentTrack, beginState: context.currentState,
                                                      endTrack: nil, endState: .stopped))
        
        chain.proceed(context)
    }
}
