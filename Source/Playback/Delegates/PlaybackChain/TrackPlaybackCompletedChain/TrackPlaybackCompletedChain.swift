//
//  TrackPlaybackCompletedChain.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

/*
    A playback chain that responds to the completion of playback of a track.
    It either plays the subsequent track in the current playback sequence, if there is one,
    or stops playback, if no further tracks are available to play.
 
    NOTE - This playback chain delegates to StartPlaybackChain and StopPlaybackChain to do most of its work.
 */
class TrackPlaybackCompletedChain: PlaybackChain {
    
    // The playback chains that are used to continue/stop playback
    private let startPlaybackChain: StartPlaybackChain
    private let stopPlaybackChain: StopPlaybackChain
    
    private let sequencer: SequencerProtocol
    
    init(_ startPlaybackChain: StartPlaybackChain, _ stopPlaybackChain: StopPlaybackChain, _ sequencer: SequencerProtocol) {
        
        self.startPlaybackChain = startPlaybackChain
        self.stopPlaybackChain = stopPlaybackChain
        self.sequencer = sequencer
        
        super.init()
    }
    
    override func execute(_ context: PlaybackRequestContext) {
        
        super.execute(context)
        
        context.requestedTrack = sequencer.subsequent()
        
        // Continue playback with the subsequent track (or stop if no subsequent track).
        context.requestedTrack != nil ? startPlaybackChain.execute(context) : stopPlaybackChain.execute(context)
    }
}
