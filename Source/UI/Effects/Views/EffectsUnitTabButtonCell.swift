//
//  EffectsUnitTabButtonCell.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

@IBDesignable
class EffectsUnitTabButtonCell: NSButtonCell {
    
//    private var selectionBoxColor: NSColor {Colors.selectedTabButtonColor}
    
    @IBInspectable var imgWidth: Int = 13
    @IBInspectable var imgHeight: Int = 13
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        drawInterior(withFrame: cellFrame, in: controlView)
    }
    
    var tabButton: EffectsUnitTabButton {
        controlView as! EffectsUnitTabButton
    }
    
    var isSelected: Bool {
        tabButton.isSelected
    }
    
    var imageColor: NSColor {
        systemColorScheme.colorForEffectsUnitState(fxUnitStateObserverRegistry.currentState(forObserver: tabButton))
    }
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        // Draw image (left aligned)
        let rectWidth: CGFloat = cellFrame.width, rectHeight: CGFloat = cellFrame.height
        let xInset = (rectWidth - CGFloat(imgWidth)) / 2
        let yInset = (rectHeight - CGFloat(imgHeight)) / 2
        
        // Raise the selected tab image by a few pixels so it is prominent
        let imgRect = cellFrame.insetBy(dx: xInset, dy: yInset).offsetBy(dx: 0, dy: isSelected ? -1 : 0)
        
        self.image = self.image?.tintedWithColor(imageColor)
        
        self.image?.draw(in: imgRect)
        
        // Selection underline
        if isSelected {
            
            let drawRect = NSRect(x: cellFrame.centerX - (imgRect.width / 2), y: cellFrame.maxY - 1,
                                  width: imgRect.width, height: 1)
            
            drawRect.fill(withColor: systemColorScheme.buttonColor)
        }
    }
}
