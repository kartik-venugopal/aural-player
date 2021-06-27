//
//  ControlBarSeekSliderCell.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class ControlBarSeekSliderCell: SeekSliderCell {
    
    override var barInsetY: CGFloat {0}
    override var barRadius: CGFloat {1}
    
    // Don't draw the knob
    override func drawKnob(_ knobRect: NSRect) {}
    
    override func barRect(flipped: Bool) -> NSRect {
        
        let superRect = super.barRect(flipped: flipped)
        return NSMakeRect(superRect.minX, 5, superRect.width, superRect.height)
    }
}
