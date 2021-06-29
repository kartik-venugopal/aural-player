//
//  ControlBarSeekSliderView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class ControlBarSeekSliderView: SeekSliderView {
    
    @IBOutlet weak var lblSeekPosition: CenterTextLabel!
    private var seekPositionDisplayType: SeekPositionDisplayType = .timeElapsed
 
    private let fontSchemesManager: FontSchemesManager = ObjectGraph.fontSchemesManager
    private let colorSchemesManager: ColorSchemesManager = ObjectGraph.colorSchemesManager
    
    var okToShowSeekPosition: () -> Bool = {true} {
        
        didSet {
            
            if player.playingTrack != nil && lblSeekPosition.isHidden {
                
                showSeekPositionLabels()
                return
            }
            
            let shouldShowLabels: Bool = okToShowSeekPosition()
            
            if !shouldShowLabels || player.playingTrack == nil, lblSeekPosition.isShown {
                
                hideSeekPositionLabels()
                return
            }
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        seekSlider.redraw()
        
        applyTheme()
    }
    
    override func initSeekPositionLabels() {//TODO
        
        lblSeekPosition?.addGestureRecognizer(NSClickGestureRecognizer(target: self,
                                                                       action: #selector(self.switchSeekPositionDisplay)))
    }
    
    @objc func switchSeekPositionDisplay() {
        
        seekPositionDisplayType = seekPositionDisplayType.toggle()
        updateSeekPositionLabels(player.seekPosition)
    }
    
    override func initSeekTimer() {//TODO
        super.initSeekTimer()
    }
    
    override func showSeekPositionLabels() {
        
        lblSeekPosition.showIf(okToShowSeekPosition())
        setSeekTimerState(true)
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
    
    func applyTheme() {
        
        applyFontScheme(fontSchemesManager.systemScheme)
        applyColorScheme(colorSchemesManager.systemScheme)
    }
    
    override func applyFontScheme(_ fontScheme: FontScheme) {
        lblSeekPosition.font = fontScheme.player.trackTimesFont
    }
    
    override func applyColorScheme(_ colorScheme: ColorScheme) {
        lblSeekPosition.textColor = colorScheme.player.trackInfoPrimaryTextColor
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

fileprivate enum SeekPositionDisplayType {
    
    case timeElapsed
    case timeRemaining
    case duration
    
    func toggle() -> SeekPositionDisplayType {
        
        switch self {
        
        case .timeElapsed:  return .timeRemaining
            
        case .timeRemaining:    return .duration
            
        case .duration:     return .timeElapsed
            
        }
    }
}
