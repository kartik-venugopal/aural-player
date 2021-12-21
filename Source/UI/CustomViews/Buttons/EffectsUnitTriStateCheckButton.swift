//
//  EffectsUnitTriStateCheckButton.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

@IBDesignable
class EffectsUnitTriStateCheckButton: NSButton {
    
    var stateFunction: (() -> EffectsUnitState)? {
        didSet {reTint()}
    }

    var unitState: EffectsUnitState {
        return stateFunction?() ?? .bypassed
    }
    
    var activeStateColor: NSColor {Colors.Effects.activeUnitStateColor}
    
    var bypassedStateColor: NSColor {Colors.Effects.bypassedUnitStateColor}
    
    var suppressedStateColor: NSColor {Colors.Effects.suppressedUnitStateColor}
        
    func stateChanged() {
        
        switch unitState {

        case .bypassed:

            image = image?.applyingTint(bypassedStateColor)
            alternateImage = alternateImage?.applyingTint(bypassedStateColor)

        case .active:

            image = image?.applyingTint(activeStateColor)
            alternateImage = alternateImage?.applyingTint(activeStateColor)

        case .suppressed:

            image = image?.applyingTint(suppressedStateColor)
            alternateImage = alternateImage?.applyingTint(suppressedStateColor)
        }
    }
    
    func reTint() {
        
        switch unitState {

        case .bypassed:

            image = image?.applyingTint(bypassedStateColor)
            alternateImage = alternateImage?.applyingTint(bypassedStateColor)

        case .active:

            image = image?.applyingTint(activeStateColor)
            alternateImage = alternateImage?.applyingTint(activeStateColor)

        case .suppressed:

            image = image?.applyingTint(suppressedStateColor)
            alternateImage = alternateImage?.applyingTint(suppressedStateColor)
        }
    }
}

extension NSImage {
    
    // Returns a copy of this image tinted with a given color. Used by several UI components for system color scheme conformance.
    func applyingTint(_ color: NSColor) -> NSImage {
        
        let image = self.copy() as! NSImage
        image.lockFocus()
        
        color.set()
        
        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        imageRect.fill(using: .sourceAtop)
        
        image.unlockFocus()
        
        return image
    }
}
