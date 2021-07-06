//
//  MenuBarVolumeSliderCell.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class MenuBarVolumeSliderCell: VolumeSliderCell {
    
    override var knobColor: NSColor {ColorConstants.white70Percent}
    override var barRadius: CGFloat {0}
    override var knobRadius: CGFloat {0}
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let knobFrame = knobRect(flipped: false)
        let halfKnobWidth = knobFrame.width / 2
        
        let leftRect = NSRect(x: aRect.minX, y: aRect.minY, width: max(halfKnobWidth, knobFrame.minX + halfKnobWidth), height: aRect.height)
        ColorConstants.white70Percent.setFill()
        leftRect.fill()
        
        let rightRect = NSRect(x: knobFrame.maxX - halfKnobWidth, y: aRect.minY, width: aRect.width - (knobFrame.maxX - halfKnobWidth), height: aRect.height)
        ColorConstants.white30Percent.setFill()
        rightRect.fill()
    }
}
