//
//  HaltPlaybackAction.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Chain of responsibility action that stops playback.
///
class HaltPlaybackAction: PlaybackChainAction {
    
    private let playerStopFunction: PlayerStopFunction
    
    init(playerStopFunction: @escaping PlayerStopFunction) {
        self.playerStopFunction = playerStopFunction
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        if context.currentState != .stopped, let playingTrack = context.currentTrack {
            
            playerStopFunction()
            playingTrack.playbackContext?.close()
        }
        
        chain.proceed(context)
    }
}
