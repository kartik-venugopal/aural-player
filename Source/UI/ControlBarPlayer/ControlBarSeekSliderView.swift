//
//  ControlBarSeekSliderView.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class ControlBarSeekSliderView: SeekSliderView {
    
    @IBOutlet weak var lblSeekPosition: CenterTextLabel!
    
    private let uiState: ControlBarPlayerUIState = objectGraph.controlBarPlayerUIState
    
    var seekPositionDisplayType: ControlBarSeekPositionDisplayType = .timeElapsed {
        
        didSet {
            
            uiState.seekPositionDisplayType = seekPositionDisplayType
            updateSeekPositionLabels(player.seekPosition)
        }
    }
 
    private let fontSchemesManager: FontSchemesManager = objectGraph.fontSchemesManager
    private let colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    
    ///
    /// Determines whether or not the seek position needs to be displayed (when a track is playing).
    ///
    var showSeekPosition: Bool = false {
       
        // When the value is updated, need to show / hide the label and update its displayed text.
        didSet {
            
            if player.playingTrack != nil {
                
                updateSeekPosition()
                showSeekPositionLabels()
                return
            }
            
            hideSeekPositionLabels()
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.seekPositionDisplayType = uiState.seekPositionDisplayType
        applyTheme()
    }
    
    override func initSeekPositionLabels() {
        
        lblSeekPosition?.addGestureRecognizer(NSClickGestureRecognizer(target: self,
                                                                       action: #selector(self.switchSeekPositionDisplay)))
    }
    
    @objc func switchSeekPositionDisplay() {
        
        seekPositionDisplayType = seekPositionDisplayType.toggle()
        updateSeekPositionLabels(player.seekPosition)
    }
    
    override func initSeekTimer() {
        super.initSeekTimer()
    }
    
    override func showSeekPositionLabels() {
        
        lblSeekPosition.showIf(showSeekPosition)
        setSeekTimerState(player.state == .playing)
    }
    
    override func hideSeekPositionLabels() {
        
        lblSeekPosition.hide()
        setSeekTimerState(false)
    }
    
    override func updateSeekPositionLabels(_ seekPos: PlaybackPosition) {
        
        switch seekPositionDisplayType {
        
        case .timeElapsed:
            
            lblSeekPosition.stringValue = ValueFormatter.formatSecondsToHMS(seekPos.timeElapsed)
            
        case .timeRemaining:
            
            let trackTimes = ValueFormatter.formatTrackTimes(seekPos.timeElapsed, seekPos.trackDuration, seekPos.percentageElapsed)
            
            lblSeekPosition.stringValue = trackTimes.remaining
            
        case .duration:
            
            lblSeekPosition.stringValue = ValueFormatter.formatSecondsToHMS(seekPos.trackDuration)
        }
    }
    
    override func playbackStateChanged(_ newState: PlaybackState) {
        setSeekTimerState(newState == .playing)
    }
    
    func applyTheme() {
        
        applyFontScheme(fontSchemesManager.systemScheme)
        applyColorScheme(colorSchemesManager.systemScheme)
    }
    
    override func applyFontScheme(_ fontScheme: FontScheme) {
        lblSeekPosition.font = fontScheme.player.trackTimesFont
    }
    
    override func applyColorScheme(_ colorScheme: ColorScheme) {
        
        lblSeekPosition.textColor = colorScheme.player.trackInfoPrimaryTextColor
        seekSlider.redraw()
    }
    
    // When the playback loop for the current playing track is changed, the seek slider needs to be updated (redrawn) to show the current loop state
    override func playbackLoopChanged(_ playbackLoop: PlaybackLoop?, _ trackDuration: Double) {
        
        if let loop = playbackLoop {
            
            let startTime = loop.startTime
            let startPerc = startTime * 100 / trackDuration
            
            // If loop start has not yet been marked, mark it (e.g. when marking chapter loops)
            seekSliderCell.markLoopStart(CGFloat(startPerc))
            
            // Use the seek slider clone to mark the exact position of the center of the slider knob, at both the start and end points of the playback loop (for rendering)
            if let loopEndTime = loop.endTime {

                let endPerc = loopEndTime * 100 / trackDuration
                seekSliderCell.markLoopEnd(CGFloat(endPerc))
            }
            
        } else {
            seekSliderCell.removeLoop()
        }

        seekSlider.redraw()
        updateSeekPosition()
    }
}
