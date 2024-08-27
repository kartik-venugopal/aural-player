//
//  HaltPlaybackAction.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
        
        if context.currentState != .stopped, let playingTrack = context.currentTrack {
            
            player.stop()
            playingTrack.playbackContext?.close()
        }
        
        chain.proceed(context)
    }
}
