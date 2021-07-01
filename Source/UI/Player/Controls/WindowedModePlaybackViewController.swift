//
//  WindowedModePlaybackViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class WindowedModePlaybackViewController: PlaybackViewController {
 
    override func initSubscriptions() {
        
        // MARK: Notifications --------------------------------------------------------------
        
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:), queue: .main)
        Messenger.subscribe(self, .player_trackNotPlayed, self.trackNotPlayed(_:))
        
        Messenger.subscribe(self, .effects_playbackRateChanged, self.playbackRateChanged(_:))
        Messenger.subscribe(self, .player_playbackLoopChanged, self.playbackLoopChanged)
        
        // MARK: Commands --------------------------------------------------------------
        
        Messenger.subscribe(self, .player_playTrack, self.performTrackPlayback(_:))
        
        Messenger.subscribe(self, .player_playOrPause, self.playOrPause)
        Messenger.subscribe(self, .player_stop, self.stop)
        Messenger.subscribe(self, .player_previousTrack, self.previousTrack)
        Messenger.subscribe(self, .player_nextTrack, self.nextTrack)
        Messenger.subscribe(self, .player_replayTrack, self.replayTrack)
        Messenger.subscribe(self, .player_seekBackward, self.seekBackward(_:))
        Messenger.subscribe(self, .player_seekForward, self.seekForward(_:))
        Messenger.subscribe(self, .player_seekBackward_secondary, self.seekBackward_secondary)
        Messenger.subscribe(self, .player_seekForward_secondary, self.seekForward_secondary)
        Messenger.subscribe(self, .player_jumpToTime, self.jumpToTime(_:))
        Messenger.subscribe(self, .player_toggleLoop, self.toggleLoop)
        
        Messenger.subscribe(self, .player_playChapter, self.playChapter(_:))
        Messenger.subscribe(self, .player_previousChapter, self.previousChapter)
        Messenger.subscribe(self, .player_nextChapter, self.nextChapter)
        Messenger.subscribe(self, .player_replayChapter, self.replayChapter)
        Messenger.subscribe(self, .player_toggleChapterLoop, self.toggleChapterLoop)
        
        Messenger.subscribe(self, .player_showOrHideTimeElapsedRemaining, playbackView.showOrHideTimeElapsedRemaining)
        Messenger.subscribe(self, .player_setTimeElapsedDisplayFormat, playbackView.setTimeElapsedDisplayFormat(_:))
        Messenger.subscribe(self, .player_setTimeRemainingDisplayFormat, playbackView.setTimeRemainingDisplayFormat(_:))
        
        guard let playbackView = self.playbackView as? WindowedModePlaybackView else {return}
        
        Messenger.subscribe(self, .applyTheme, playbackView.applyTheme)
        Messenger.subscribe(self, .applyFontScheme, playbackView.applyFontScheme(_:))
        Messenger.subscribe(self, .applyColorScheme, playbackView.applyColorScheme(_:))
        Messenger.subscribe(self, .player_changeSliderColors, playbackView.changeSliderColors)
        Messenger.subscribe(self, .changeFunctionButtonColor, playbackView.changeFunctionButtonColor(_:))
        Messenger.subscribe(self, .changeToggleButtonOffStateColor, playbackView.changeToggleButtonOffStateColor(_:))
        Messenger.subscribe(self, .player_changeSliderValueTextColor, playbackView.changeSliderValueTextColor(_:))
    }
    
    func performTrackPlayback(_ command: TrackPlaybackCommandNotification) {
        
        switch command.type {
            
        case .index:
            
            if let index = command.index {
                playTrackWithIndex(index)
            }
            
        case .track:
            
            if let track = command.track {
                playTrack(track)
            }
            
        case .group:
            
            if let group = command.group {
                playGroup(group)
            }
        }
    }
    
    func playTrackWithIndex(_ trackIndex: Int) {
        player.play(trackIndex, PlaybackParams.defaultParams())
    }
    
    func playTrack(_ track: Track) {
        player.play(track, PlaybackParams.defaultParams())
    }
    
    func playGroup(_ group: Group) {
        player.play(group, PlaybackParams.defaultParams())
    }
    
    func seekBackward_secondary() {
        
        player.seekBackwardSecondary()
        playbackView.updateSeekPosition()
    }
    
    func seekForward_secondary() {
        
        player.seekForwardSecondary()
        playbackView.updateSeekPosition()
    }
    
    func jumpToTime(_ time: Double) {
        
        player.seekToTime(time)
        playbackView.updateSeekPosition()
    }
    
    // Returns a view that marks the current position of the seek slider knob.
    var seekPositionMarkerView: NSView! {
        
        (playbackView as? WindowedModePlaybackView)?.positionSeekPositionMarkerView()
        return (playbackView as? WindowedModePlaybackView)?.seekPositionMarker
    }
    
    // MARK: Chapter playback functions ------------------------------------------------------------
    
    func playChapter(_ index: Int) {
        
        player.playChapter(index)
        playbackView.playbackLoopChanged(player.playbackLoop, player.playingTrack?.duration ?? 0)
        playbackView.playbackStateChanged(player.state)
    }
    
    func previousChapter() {
        
        player.previousChapter()
        playbackView.playbackLoopChanged(player.playbackLoop, player.playingTrack?.duration ?? 0)
        playbackView.playbackStateChanged(player.state)
    }
    
    func nextChapter() {
        
        player.nextChapter()
        playbackView.playbackLoopChanged(player.playbackLoop, player.playingTrack?.duration ?? 0)
        playbackView.playbackStateChanged(player.state)
    }
    
    func replayChapter() {
        
        player.replayChapter()
        playbackView.updateSeekPosition()
        playbackView.playbackStateChanged(player.state)
    }
    
    func toggleChapterLoop() {
        
        _ = player.toggleChapterLoop()
        playbackView.playbackLoopChanged(player.playbackLoop, player.playingTrack?.duration ?? 0)
        
        Messenger.publish(.player_playbackLoopChanged)
    }
}
