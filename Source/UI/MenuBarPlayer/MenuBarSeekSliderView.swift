//
//  MenuBarSeekSliderView.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

class MenuBarSeekSliderView: SeekSliderView {
    
    override func initSeekPositionLabels() {}
    
    override func updateSeekPositionLabels(_ seekPos: PlaybackPosition) {
        
        let trackTimes = ValueFormatter.formatTrackTimes(seekPos.timeElapsed, seekPos.trackDuration, seekPos.percentageElapsed, .formatted, .formatted)
        
        lblTimeElapsed?.stringValue = trackTimes.elapsed
        lblTimeRemaining?.stringValue = trackTimes.remaining
    }
    
    func stopUpdatingSeekPosition() {
        setSeekTimerState(false)
    }
    
    func resumeUpdatingSeekPosition() {
        
        updateSeekPosition()
        setSeekTimerState(true)
    }
}
