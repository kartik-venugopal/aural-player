//
//  TrackInfoPopoverTabButtonCell.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class TrackInfoPopoverTabButtonCell: TabGroupButtonCell {
    
    private let _selectionBoxColor: NSColor = NSColor.black
    
    override var unselectedTextColor: NSColor {.white70Percent}
    
    override var textFont: NSFont {.largeTabButtonFont}
    override var boldTextFont: NSFont {.largeTabButtonFont}
    
    override var fillBeforeBorder: Bool {false}
    override var borderRadius: CGFloat {4}
    override var borderLineWidth: CGFloat {1.5}
    override var selectionBoxColor: NSColor {_selectionBoxColor}
}
