//
//  ControlBarPlaybackViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class ControlBarPlaybackViewController: PlaybackViewController {
    
    override var displaysChapterIndicator: Bool {false}
    
    override func initSubscriptions() {
        
        // MARK: Notifications --------------------------------------------------------------
        
        Messenger.subscribe(self, .player_playOrPause, self.playOrPause)
        Messenger.subscribe(self, .player_stop, self.stop)
        Messenger.subscribe(self, .player_replayTrack, self.replayTrack)
        Messenger.subscribe(self, .player_previousTrack, self.previousTrack)
        Messenger.subscribe(self, .player_nextTrack, self.nextTrack)
        Messenger.subscribe(self, .player_seekBackward, self.seekBackward(_:))
        Messenger.subscribe(self, .player_seekForward, self.seekForward(_:))
        Messenger.subscribe(self, .player_jumpToTime, self.jumpToTime(_:))
        
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:), queue: .main)
        Messenger.subscribe(self, .player_trackNotPlayed, self.trackNotPlayed(_:))
        
        Messenger.subscribe(self, .effects_playbackRateChanged, self.playbackRateChanged(_:))
        Messenger.subscribe(self, .player_playbackLoopChanged, self.playbackLoopChanged)
        
        Messenger.subscribe(self, .applyTheme, (playbackView as! ControlBarPlaybackView).applyTheme)
        Messenger.subscribe(self, .applyFontScheme, playbackView.applyFontScheme(_:))
        Messenger.subscribe(self, .applyColorScheme, playbackView.applyColorScheme(_:))
    }
}
