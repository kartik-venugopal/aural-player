//
//  MasterPresetView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class MasterPresetView: MasterView {
    
    override func awakeFromNib() {
        
        buttons = [btnEQBypass, btnPitchBypass, btnTimeBypass, btnReverbBypass, btnDelayBypass, btnFilterBypass]
        images = [imgEQBypass, imgPitchBypass, imgTimeBypass, imgReverbBypass, imgDelayBypass, imgFilterBypass]
        labels = [lblEQ, lblPitch, lblTime, lblReverb, lblDelay, lblFilter]
    }
}
