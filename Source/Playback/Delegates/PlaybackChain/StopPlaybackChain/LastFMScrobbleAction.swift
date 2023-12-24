//
//  LastFMScrobbleAction.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

class LastFMScrobbleAction: PlaybackChainAction {
    
    private lazy var lastFMClient: LastFM_WSClientProtocol = objectGraph.lastFMClient
    private lazy var preferences: LastFMPreferences = objectGraph.preferences.metadataPreferences.lastFM
    private lazy var history: HistoryDelegateProtocol = objectGraph.historyDelegate
    
    private static let maxPlaybackTime: Double = 240    // 4 minutes
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        /*
         
         From: https://www.last.fm/api/scrobbling
         ----------------------------------------
         
         A track should only be scrobbled when the following conditions have been met:
         
         - The track must be longer than 30 seconds.
         - And the track has been played for at least half its duration, or for 4 minutes (whichever occurs earlier.)
         
         */
        
        if preferences.enableScrobbling,
           let sessionKey = preferences.sessionKey,
           let stoppedTrack = context.currentTrack,
           stoppedTrack.canBeScrobbledOnLastFM,
           let historyLastPlayedItem = self.history.lastPlayedItem, historyLastPlayedItem.file == stoppedTrack.file {
            
            let now = Date()
            let playbackTime = now.timeIntervalSince(historyLastPlayedItem.time)
            
            if playbackTime >= min(stoppedTrack.duration / 2, Self.maxPlaybackTime) {
                
                DispatchQueue.global(qos: .background).async {
                    self.lastFMClient.scrobbleTrack(track: stoppedTrack, timestamp: historyLastPlayedItem.time.epochTime, usingSessionKey: sessionKey)
                }
            }
        }
        
        chain.proceed(context)
    }
}

extension Date {
    
    static var nowEpochTime: Int {
        Int(NSDate().timeIntervalSince1970)
    }
    
    var epochTime: Int {
        Int(timeIntervalSince1970)
    }
}
