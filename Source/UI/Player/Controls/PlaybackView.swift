//
//  PlaybackView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View that encapsulates all playback-related controls (play/pause, prev/next track, seeking, segment looping).
*/
class PlaybackView: NSView {
    
    // Fields that display/control seek position within the playing track
    @IBOutlet weak var sliderView: SeekSliderView!
   
    // Toggle buttons (their images change)
    @IBOutlet weak var btnPlayPause: OnOffImageButton!
    @IBOutlet weak var btnLoop: MultiStateImageButton!
    
    // Buttons whose tool tips may change
    @IBOutlet weak var btnPreviousTrack: TrackPeekingButton!
    @IBOutlet weak var btnNextTrack: TrackPeekingButton!
    
    @IBOutlet weak var btnSeekBackward: TintedImageButton!
    @IBOutlet weak var btnSeekForward: TintedImageButton!
    
    // Delegate that retrieves playback sequencing info (previous/next track)
    private let sequencer: SequencerInfoDelegateProtocol = objectGraph.sequencerInfoDelegate
    
    // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's off state button color.
    var offStateTintFunction: TintFunction {{.gray}}
    
    // When the buttons are in an "On" state, they should be tinted according to the system color scheme's function button color.
    var onStateTintFunction: TintFunction {{.white}}
    
    var seekSliderValue: Double {sliderView.seekSliderValue}
    
    var functionButtons: [Tintable] = []
    
    override func awakeFromNib() {
        
        btnLoop.stateImageMappings = [(PlaybackLoopState.none, (Images.imgLoop, offStateTintFunction)), (PlaybackLoopState.started, (Images.imgLoopStarted, onStateTintFunction)), (PlaybackLoopState.complete, (Images.imgLoop, onStateTintFunction))]

        // Play/pause button does not really have an "off" state
        btnPlayPause.offStateTintFunction = onStateTintFunction
        
        // Button tool tips
        btnPreviousTrack.toolTipFunction = {[weak self]
            () -> String? in

            if let prevTrack = self?.sequencer.peekPrevious() {
                return String(format: "Previous track: '%@'", prevTrack.displayName)
            }

            return nil
        }

        btnNextTrack.toolTipFunction = {[weak self]
            () -> String? in

            if let nextTrack = self?.sequencer.peekNext() {
                return String(format: "Next track: '%@'", nextTrack.displayName)
            }

            return nil
        }

        [btnPreviousTrack, btnNextTrack].forEach {$0?.updateTooltip()}
        
        // MARK: Update controls based on current player state
        
        let player: PlaybackDelegateProtocol = objectGraph.playbackDelegate
        
        btnPlayPause.onIf(player.state == .playing)
        
        if let loop = player.playbackLoop {
            btnLoop.switchState(loop.isComplete ? PlaybackLoopState.complete : PlaybackLoopState.started)
        } else {
            btnLoop.switchState(PlaybackLoopState.none)
        }
        
        functionButtons = [btnLoop, btnPlayPause, btnPreviousTrack, btnNextTrack, btnSeekBackward, btnSeekForward]
    }
    
    // When the playback state changes (e.g. playing -> paused), fields may need to be updated
    func playbackStateChanged(_ newState: PlaybackState) {
        
        btnPlayPause.onIf(newState == .playing)
        sliderView.playbackStateChanged(newState)
    }

    // When the playback loop for the current playing track is changed, the seek slider needs to be updated (redrawn) to show the current loop state
    func playbackLoopChanged(_ playbackLoop: PlaybackLoop?, _ trackDuration: Double) {

        // Update loop button image
        if let loop = playbackLoop {
            btnLoop.switchState(loop.isComplete ? PlaybackLoopState.complete: PlaybackLoopState.started)

        } else {
            btnLoop.switchState(PlaybackLoopState.none)
        }
        
        sliderView.playbackLoopChanged(playbackLoop, trackDuration)
    }

    func trackChanged(_ playbackState: PlaybackState, _ loop: PlaybackLoop?, _ newTrack: Track?) {
        
        btnPlayPause.onIf(playbackState == .playing)
        btnLoop.switchState(loop != nil ? PlaybackLoopState.complete : PlaybackLoopState.none)
        [btnPreviousTrack, btnNextTrack].forEach({$0?.updateTooltip()})
        
        sliderView.trackChanged(loop, newTrack)
    }
    
    func showOrHideTimeElapsedRemaining() {
        sliderView.showOrHideTimeElapsedRemaining()
    }
    
    func updateSeekPosition() {
        sliderView.updateSeekPosition()
    }
    
    func playbackRateChanged(_ rate: Float, _ playbackState: PlaybackState) {
        sliderView.playbackRateChanged(rate, playbackState)
    }
    
    func setTimeElapsedDisplayFormat(_ format: TimeElapsedDisplayType) {
        sliderView.setTimeElapsedDisplayFormat(format)
    }
    
    func setTimeRemainingDisplayFormat(_ format: TimeRemainingDisplayType) {
        sliderView.setTimeRemainingDisplayFormat(format)
    }
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        sliderView.applyFontScheme(fontScheme)
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        
        // This call will also take care of toggle buttons
        changeFunctionButtonColor(scheme.general.functionButtonColor)
        sliderView.applyColorScheme(scheme)
    }
    
    func changeSliderColors() {
        sliderView.changeSliderColors()
    }
    
    func changeSliderValueTextColor(_ color: NSColor) {
        sliderView.changeSliderValueTextColor(color)
    }
    
    func changeFunctionButtonColor(_ color: NSColor) {
        functionButtons.forEach {$0.reTint()}
    }
    
    func changeToggleButtonOffStateColor(_ color: NSColor) {
        
        // Only these buttons have off states that look different from their on states
        btnLoop.reTint()
    }
}
