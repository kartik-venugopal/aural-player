//
//  MenuBarSeekSliderCell.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class MenuBarSeekSliderCell: SeekSliderCell {
    
    override var knobColor: NSColor {.white70Percent}
    override var loopColor: NSColor {.white}
    
    override func drawLeftRect(inRect rect: NSRect, knobFrame: NSRect) {
        
        let halfKnobWidth = knobFrame.width / 2
        
        let leftRect = NSRect(x: rect.minX, y: rect.minY,
                              width: max(halfKnobWidth, knobFrame.minX + halfKnobWidth), height: rect.height)
        
        leftRect.fill(withColor: .white70Percent)
    }
    
    override func drawRightRect(inRect rect: NSRect, knobFrame: NSRect) {
        
        let halfKnobWidth = knobFrame.width / 2
        
        let rightRect = NSRect(x: knobFrame.maxX - halfKnobWidth, y: rect.minY,
                               width: rect.width - (knobFrame.maxX - halfKnobWidth), height: rect.height)
        
        rightRect.fill(withColor: .white30Percent)
    }
}
