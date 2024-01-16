//
//  ControlBarPlaybackViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class ControlBarPlaybackViewController: PlaybackViewController {
    
    override var displaysChapterIndicator: Bool {false}
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        // MARK: Notifications --------------------------------------------------------------
        
        messenger.subscribe(to: .player_playOrPause, handler: playOrPause)
        messenger.subscribe(to: .player_stop, handler: stop)
        messenger.subscribe(to: .player_replayTrack, handler: replayTrack)
        messenger.subscribe(to: .player_previousTrack, handler: previousTrack)
        messenger.subscribe(to: .player_nextTrack, handler: nextTrack)
        messenger.subscribe(to: .player_seekBackward, handler: seekBackward(_:))
        messenger.subscribe(to: .player_seekForward, handler: seekForward(_:))
        messenger.subscribe(to: .player_jumpToTime, handler: jumpToTime(_:))
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribe(to: .player_trackNotPlayed, handler: trackNotPlayed(_:))
        
        messenger.subscribe(to: .effects_playbackRateChanged, handler: playbackRateChanged(_:))
        messenger.subscribe(to: .player_playbackLoopChanged, handler: playbackLoopChanged)
        
        messenger.subscribe(to: .applyTheme, handler: (playbackView as! ControlBarPlaybackView).applyTheme)
        messenger.subscribe(to: .applyFontScheme, handler: playbackView.applyFontScheme(_:))
        messenger.subscribe(to: .applyColorScheme, handler: playbackView.applyColorScheme(_:))
    }
}
