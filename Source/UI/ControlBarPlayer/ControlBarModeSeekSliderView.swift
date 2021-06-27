//
//  ControlBarModeSeekSliderView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

class ControlBarModeSeekSliderView: SeekSliderView {
 
    private let fontSchemesManager: FontSchemesManager = ObjectGraph.fontSchemesManager
    private let colorSchemesManager: ColorSchemesManager = ObjectGraph.colorSchemesManager
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
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
