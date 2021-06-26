//
//  ControlBarModePlaybackViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class ControlBarModePlaybackViewController: PlaybackViewController {
    
    override var displaysChapterIndicator: Bool {false}
    
    override func initSubscriptions() {
        
        // MARK: Notifications --------------------------------------------------------------
        
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:), queue: .main)
        Messenger.subscribe(self, .player_trackNotPlayed, self.trackNotPlayed(_:))
        
        Messenger.subscribe(self, .effects_playbackRateChanged, self.playbackRateChanged(_:))
        Messenger.subscribe(self, .player_playbackLoopChanged, self.playbackLoopChanged)
    }
}
