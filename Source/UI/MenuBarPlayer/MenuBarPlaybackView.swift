//
//  MenuBarPlaybackView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

class MenuBarPlaybackView: PlaybackView {
    
    // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's off state button color.
    override var offStateTintFunction: TintFunction {{ColorConstants.white40Percent}}

    // When the buttons are in an "On" state, they should be tinted according to the system color scheme's function button color.
    override var onStateTintFunction: TintFunction {{ColorConstants.white70Percent}}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        btnPlayPause.onStateTintFunction = {ColorConstants.white70Percent}
        [btnPreviousTrack, btnNextTrack, btnSeekBackward, btnSeekForward].forEach {$0?.tintFunction = {ColorConstants.white70Percent}}
    }
}
