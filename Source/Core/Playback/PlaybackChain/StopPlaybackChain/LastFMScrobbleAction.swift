//
//  LastFMScrobbleAction.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class LastFMScrobbleAction: PlaybackChainAction {
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        if let stoppedTrack = context.currentTrack {
            lastFMClient.scrobbleTrackIfEligible(stoppedTrack)
        }
        
        chain.proceed(context)
    }
}
