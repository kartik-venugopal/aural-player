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
    
    private static let minTrackLength: Double = 30      // 30 seconds
    private static let maxPlaybackTime: Double = 240    // 4 minutes
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        /*
         
         From: https://www.last.fm/api/scrobbling
         ----------------------------------------
         
         A track should only be scrobbled when the following conditions have been met:
         
         - The track must be longer than 30 seconds.
         - And the track has been played for at least half its duration, or for 4 minutes (whichever occurs earlier.)
         
         */
        
        if let sessionKey = preferences.sessionKey,
           preferences.enableScrobbling,
           let stoppedTrack = context.currentTrack,
           stoppedTrack.duration > Self.minTrackLength,
           context.currentSeekPosition >= min(stoppedTrack.duration / 2, Self.maxPlaybackTime) {
            
            DispatchQueue.global(qos: .background).async {
                
                // TODO: Timestamp - time track STARTED playing, not STOPPED playing !!! (look in history ???)
                
                let hist = objectGraph.historyDelegate
                
                if let last = hist.lastPlayedItem, last.file == stoppedTrack.file {
                    print("Start date: \(last.time) \(last.time.timeIntervalSince1970)")
                }
                
                self.lastFMClient.scrobbleTrack(track: stoppedTrack, timestamp: NSDate.epochTime, usingSessionKey: sessionKey)
            }
        }
        
        chain.proceed(context)
    }
}

extension NSDate {
    
    static var epochTime: Int {
        Int(NSDate().timeIntervalSince1970)
    }
}
