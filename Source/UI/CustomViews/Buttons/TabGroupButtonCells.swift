//
//  TabGroupButtonCells.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

// Base class for all tab group button cells
class TabGroupButtonCell: NSButtonCell {
    
    // Highlighting colors the button text to indicate that the effects unit represented by this button is currently active
    var shouldHighlight: Bool = false
    var highlightColor: NSColor = .tabViewButtonTextColor
    
    var fillBeforeBorder: Bool {true}
    var borderInsetX: CGFloat {1}
    var borderInsetY: CGFloat {1}
    var borderRadius: CGFloat {1}
    var borderLineWidth: CGFloat {2}
    var selectionBoxColor: NSColor {.tabViewSelectionBoxColor}
    
    var unselectedTextColor: NSColor {.tabViewButtonTextColor}
    var selectedTextColor: NSColor {.defaultSelectedLightTextColor}
    var textFont: NSFont {.tabViewButtonFont}
    var boldTextFont: NSFont {.tabViewButtonBoldFont}
    
    var yOffset: CGFloat {0}
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        drawInterior(withFrame: cellFrame, in: controlView)
    }
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        var drawRect: NSRect = cellFrame
        
        // Selection box
        if isOn {
            
            drawRect = cellFrame.insetBy(dx: borderInsetX, dy: borderInsetY)
            NSBezierPath.fillRoundedRect(drawRect, radius: borderRadius, withColor: selectionBoxColor)
        }
     
        // Title
        let textColor = shouldHighlight ? highlightColor : (isOff ? unselectedTextColor : selectedTextColor)
        let font = isOn ? boldTextFont : textFont
        
        title.drawCentered(in: drawRect, withFont: font, andColor: textColor, yOffset: yOffset)
    }
}

class ModalDialogTabButtonCell: TabGroupButtonCell {
    
    override var fillBeforeBorder: Bool {false}
    override var borderRadius: CGFloat {4}
    override var borderLineWidth: CGFloat {1.5}
    override var selectionBoxColor: NSColor {.black}
}

class ContrastedModalDialogTabButtonCell: TabGroupButtonCell {
    
    override var selectionBoxColor: NSColor {.white70Percent}
    override var selectedTextColor: NSColor {.black}
}

class EQPreviewTabButtonCell: TabGroupButtonCell {
    override var selectionBoxColor: NSColor {.white15Percent}
}
