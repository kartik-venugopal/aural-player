//
//  SeekSliderView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
   View that encapsulates the seek slider and seek time labels.
*/
class SeekSliderView: NSView {
    
    // Fields that display/control seek position within the playing track
    @IBOutlet weak var lblTimeElapsed: VALabel!
    @IBOutlet weak var lblTimeRemaining: VALabel!
    
    // Shows the time elapsed for the currently playing track, and allows arbitrary seeking within the track
    @IBOutlet weak var seekSlider: NSSlider!
    @IBOutlet weak var seekSliderCell: SeekSliderCell!
    
    // A clone of the seek slider, used to render the segment playback loop
    @IBOutlet weak var seekSliderClone: NSSlider!
    @IBOutlet weak var seekSliderCloneCell: SeekSliderCell!
    
    // Timer that periodically updates the seek position slider and label
    var seekTimer: RepeatingTaskExecutor?
    
    // Delegate representing the Time effects unit
    let timeUnit: TimeStretchUnitDelegateProtocol = ObjectGraph.audioGraphDelegate.timeUnit
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    let player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
    
    var seekSliderValue: Double {seekSlider.doubleValue}
    
    override func awakeFromNib() {
        
        // Allow clicks on the seek time display labels to switch to different display formats.
        lblTimeElapsed?.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(self.switchTimeElapsedDisplayAction)))
        
        lblTimeRemaining?.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(self.switchTimeRemainingDisplayAction)))
        
        // MARK: Update controls based on current player state
        
        let seekTimerInterval = (1000 / (2 * timeUnit.effectiveRate)).roundedInt
        
        seekTimer = RepeatingTaskExecutor(intervalMillis: seekTimerInterval, task: {[weak self] in
            self?.updateSeekPosition()
        }, queue: .main)
        
        let player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
        
        if let track = player.playingTrack {
            
            playbackLoopChanged(player.playbackLoop, track.duration)
            seekSlider.enable()
            seekSlider.show()
            
            [lblTimeElapsed, lblTimeRemaining].forEach({$0?.showIf(PlayerViewState.showTimeElapsedRemaining)})
            setSeekTimerState(player.state == .playing)
            
        } else {
            noTrackPlaying()
        }
    }
    
    @IBAction func switchTimeElapsedDisplayAction(_ sender: Any) {
        
        PlayerViewState.timeElapsedDisplayType = PlayerViewState.timeElapsedDisplayType.toggle()
        updateSeekPosition()
    }
    
    @IBAction func switchTimeRemainingDisplayAction(_ sender: Any) {
        
        PlayerViewState.timeRemainingDisplayType = PlayerViewState.timeRemainingDisplayType.toggle()
        updateSeekPosition()
    }
    
    func setTimeElapsedDisplayFormat(_ format: TimeElapsedDisplayType) {
        updateSeekPosition()
    }
    
    func setTimeRemainingDisplayFormat(_ format: TimeRemainingDisplayType) {
        updateSeekPosition()
    }
    
    func trackStartedPlaying() {
        
        updateSeekPosition()
        seekSlider.enable()
        seekSlider.show()
        
        [lblTimeElapsed, lblTimeRemaining].forEach({$0?.showIf(PlayerViewState.showTimeElapsedRemaining)})
        setSeekTimerState(true)
    }
    
    func noTrackPlaying() {
        
        if lblTimeElapsed != nil {
            NSView.hideViews(lblTimeElapsed, lblTimeRemaining, seekSlider)
        } else {
            seekSlider.hide()
        }
        
        seekSliderCell.removeLoop()
        seekSlider.doubleValue = 0
        seekSlider.disable()
        setSeekTimerState(false)
    }
    
    func updateSeekPosition() {
        
        let seekPosn = player.seekPosition
        seekSlider.doubleValue = seekPosn.percentageElapsed
        
        let trackTimes = ValueFormatter.formatTrackTimes(seekPosn.timeElapsed, seekPosn.trackDuration, seekPosn.percentageElapsed, PlayerViewState.timeElapsedDisplayType, PlayerViewState.timeRemainingDisplayType)
        
        lblTimeElapsed?.stringValue = trackTimes.elapsed
        lblTimeRemaining?.stringValue = trackTimes.remaining
        
        for task in SeekTimerTaskQueue.tasksArray {
            task()
        }
    }
    
    func setSeekTimerState(_ timerOn: Bool) {
        timerOn ? seekTimer?.startOrResume() : seekTimer?.pause()
    }
    
    // When the playback state changes (e.g. playing -> paused), fields may need to be updated
    func playbackStateChanged(_ newState: PlaybackState) {
        setSeekTimerState(newState == .playing)
    }
    
    // When the playback loop for the current playing track is changed, the seek slider needs to be updated (redrawn) to show the current loop state
    func playbackLoopChanged(_ playbackLoop: PlaybackLoop?, _ trackDuration: Double) {
        
        if let loop = playbackLoop {
            
            // If loop start has not yet been marked, mark it (e.g. when marking chapter loops)
            
            seekSliderClone.doubleValue = loop.startTime * 100 / trackDuration
            seekSliderCell.markLoopStart(seekSliderCloneCell.knobCenter)
            
            // Use the seek slider clone to mark the exact position of the center of the slider knob, at both the start and end points of the playback loop (for rendering)
            if let loopEndTime = loop.endTime {
                
                seekSliderClone.doubleValue = loopEndTime * 100 / trackDuration
                seekSliderCell.markLoopEnd(seekSliderCloneCell.knobCenter)
            }
            
        } else {
            seekSliderCell.removeLoop()
        }

        seekSlider.redraw()
        updateSeekPosition()
    }
    
    func trackChanged(_ loop: PlaybackLoop?, _ newTrack: Track?) {
        
        if let track = newTrack {
            
            playbackLoopChanged(loop, track.duration)
            trackStartedPlaying()
            
        } else {
            
            noTrackPlaying()
        }
    }
    
    func showOrHideTimeElapsedRemaining() {
        [lblTimeElapsed, lblTimeRemaining].forEach {$0?.showIf(PlayerViewState.showTimeElapsedRemaining)}
    }
    
    // When the playback rate changes (caused by the Time Stretch effects unit), the seek timer interval needs to be updated, to ensure that the seek position fields are updated fast/slow enough to match the new playback rate.
    func playbackRateChanged(_ rate: Float, _ playbackState: PlaybackState) {
        
        let interval = (1000 / (2 * rate)).roundedInt
        
        if interval != seekTimer?.interval {
            
            seekTimer?.stop()
            
            seekTimer = RepeatingTaskExecutor(intervalMillis: interval, task: {[weak self] in
                self?.updateSeekPosition()
            }, queue: .main)
            
            setSeekTimerState(playbackState == .playing)
        }
    }
}
