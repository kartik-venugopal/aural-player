//
//  MarkLastPlaybackPositionAction.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class MarkLastPlaybackPositionAction: PlaybackChainAction {
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        if let stoppedTrack = context.currentTrack {
            
            // If the track finished playing, then mark the position as 0 (resume from beginning).
            history.markLastPlaybackPosition(context.currentSeekPosition >= stoppedTrack.duration ? 0 : context.currentSeekPosition)
        }
        
        chain.proceed(context)
    }
}
