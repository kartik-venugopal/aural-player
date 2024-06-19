//
//  EndPlaybackSequenceAction.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
    
    private let playQueue: PlayQueueProtocol
    
    private lazy var messenger = Messenger(for: self)
    
    init(_ playQueue: PlayQueueProtocol) {
        self.playQueue = playQueue
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        messenger.publish(PreTrackPlaybackNotification(oldTrack: context.currentTrack, oldState: context.currentState, newTrack: nil))
        
        playQueue.stop()
        
        messenger.publish(TrackTransitionNotification(beginTrack: context.currentTrack, beginState: context.currentState,
                                                      endTrack: nil, endState: .stopped))
        
        chain.proceed(context)
    }
}
