//
//  EndPlaybackSequenceAction.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

/*
   Action that ends the sequencer's playback sequence and notifies observers.
*/
class EndPlaybackSequenceAction: PlaybackChainAction {
    
    private let sequencer: SequencerProtocol
    
    init(_ sequencer: SequencerProtocol) {
        self.sequencer = sequencer
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        Messenger.publish(PreTrackPlaybackNotification(oldTrack: context.currentTrack, oldState: context.currentState, newTrack: nil))
        
        sequencer.end()
        
        Messenger.publish(TrackTransitionNotification(beginTrack: context.currentTrack, beginState: context.currentState,
                                                      endTrack: nil, endState: .noTrack))
        
        chain.proceed(context)
    }
}
