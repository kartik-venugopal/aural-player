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
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackTransitioned(_:), queue: .main)
        messenger.subscribe(to: .player_trackNotPlayed, handler: trackNotPlayed(_:))
        
        messenger.subscribe(to: .effects_playbackRateChanged, handler: playbackRateChanged(_:))
        messenger.subscribe(to: .player_playbackLoopChanged, handler: playbackLoopChanged)
        
        // MARK: Commands --------------------------------------------------------------
        
        messenger.subscribe(to: .player_playTrack, handler: performTrackPlayback(_:))
        
        messenger.subscribe(to: .player_playOrPause, handler: playOrPause)
        messenger.subscribe(to: .player_stop, handler: stop)
        messenger.subscribe(to: .player_previousTrack, handler: previousTrack)
        messenger.subscribe(to: .player_nextTrack, handler: nextTrack)
        messenger.subscribe(to: .player_replayTrack, handler: replayTrack)
        messenger.subscribe(to: .player_seekBackward, handler: seekBackward(_:))
        messenger.subscribe(to: .player_seekForward, handler: seekForward(_:))
        messenger.subscribe(to: .player_seekBackward_secondary, handler: seekBackward_secondary)
        messenger.subscribe(to: .player_seekForward_secondary, handler: seekForward_secondary)
        messenger.subscribe(to: .player_jumpToTime, handler: jumpToTime(_:))
        messenger.subscribe(to: .player_toggleLoop, handler: toggleLoop)
        
        messenger.subscribe(to: .player_playChapter, handler: playChapter(_:))
        messenger.subscribe(to: .player_previousChapter, handler: previousChapter)
        messenger.subscribe(to: .player_nextChapter, handler: nextChapter)
        messenger.subscribe(to: .player_replayChapter, handler: replayChapter)
        messenger.subscribe(to: .player_toggleChapterLoop, handler: toggleChapterLoop)
        
        messenger.subscribe(to: .player_showOrHideTimeElapsedRemaining, handler: playbackView.showOrHideTimeElapsedRemaining)
        messenger.subscribe(to: .player_setTimeElapsedDisplayFormat, handler: playbackView.setTimeElapsedDisplayFormat(_:))
        messenger.subscribe(to: .player_setTimeRemainingDisplayFormat, handler: playbackView.setTimeRemainingDisplayFormat(_:))
        
        guard let playbackView = self.playbackView as? WindowedModePlaybackView else {return}
        
        messenger.subscribe(to: .applyTheme, handler: playbackView.applyTheme)
        messenger.subscribe(to: .applyFontScheme, handler: playbackView.applyFontScheme(_:))
        messenger.subscribe(to: .applyColorScheme, handler: playbackView.applyColorScheme(_:))
        messenger.subscribe(to: .player_changeSliderColors, handler: playbackView.changeSliderColors)
        messenger.subscribe(to: .changeFunctionButtonColor, handler: playbackView.changeFunctionButtonColor(_:))
        messenger.subscribe(to: .changeToggleButtonOffStateColor, handler: playbackView.changeToggleButtonOffStateColor(_:))
        messenger.subscribe(to: .player_changeSliderValueTextColor, handler: playbackView.changeSliderValueTextColor(_:))
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
        
        messenger.publish(.player_playbackLoopChanged)
    }
}
