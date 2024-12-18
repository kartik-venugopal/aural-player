//
//  LastFMScrobbleAction.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class LastFMScrobbleAction: PlaybackChainAction {
    
    private var lastFMPreferences: LastFMPreferences {preferences.metadataPreferences.lastFM}
    private static let maxPlaybackTime: Double = 240    // 4 minutes
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        /*
         
         From: https://www.last.fm/api/scrobbling
         ----------------------------------------
         
         A track should only be scrobbled when the following conditions have been met:
         
         - The track must be longer than 30 seconds.
         - And the track has been played for at least half its duration, or for 4 minutes (whichever occurs earlier.)
         
         */
        
        if lastFMPreferences.enableScrobbling.value,
           let stoppedTrack = context.currentTrack,
           stoppedTrack.canBeScrobbledOnLastFM,
           let historyLastPlayedItem = historyDelegate.lastPlayedItem, historyLastPlayedItem.track == stoppedTrack {
            
            let now = Date()
            let playbackTime = now.timeIntervalSince(historyLastPlayedItem.lastEventTime)
            
            if playbackTime >= min(stoppedTrack.duration / 2, Self.maxPlaybackTime) {
                
                DispatchQueue.global(qos: .background).async {
                    lastFMClient.scrobbleTrack(track: stoppedTrack, timestamp: historyLastPlayedItem.lastEventTime.epochTime)
                }
            }
        }
        
        chain.proceed(context)
    }
}
