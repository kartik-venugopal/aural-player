//
// UpdateHistoryAction.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

///
/// Chain of responsibility action that initiates playback of a requested track.
///
class UpdateHistoryAction: PlaybackChainAction {
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        // Cannot proceed if no requested track is specified.
        guard let newTrack = context.requestedTrack else {
            
            chain.terminate(context, NoRequestedTrackError.instance)
            return
        }
        
        history.trackPlayed(newTrack)
        
        chain.proceed(context)
    }
}
