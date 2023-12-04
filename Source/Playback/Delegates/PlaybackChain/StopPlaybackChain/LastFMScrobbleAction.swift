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
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        if let stoppedTrack = context.currentTrack {
            
            print("Scrobbling Stopped Track: \(stoppedTrack.displayName) ...")
            
            DispatchQueue.global(qos: .background).async {
                self.lastFMClient.scrobbleTrack(track: stoppedTrack, timestamp: NSDate.epochTime, usingSessionKey: "JJmg8P7wKaw6bqiVYl48o-QQPr9ApYHo")
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
