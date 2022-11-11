//
//  HaltPlaybackAction.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Chain of responsibility action that stops playback.
///
class HaltPlaybackAction: PlaybackChainAction {
    
    private let player: PlayerProtocol
    
    init(_ player: PlayerProtocol) {
        self.player = player
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        if context.currentState != .noTrack, let playingTrack = context.currentTrack {
            
            player.stop()
            
            // TODO: What if the requested track is the same as the current track ? Should we not close the context then ???
            playingTrack.playbackContext?.close()
        }
        
        chain.proceed(context)
    }
}
