//
//  EffectsUnitToggle.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

/*
    A special image button to which a tint can be applied, to conform to the current system color scheme.
 */
@IBDesignable
class EffectsUnitToggle: NSButton, FXUnitStateObserver {
    
    override var state: NSControl.StateValue {
        
        get {
            super.state
        }
        
        set {
            super.state = newValue
            redraw()
        }
    }
    
    func redraw(forState newState: EffectsUnitState) {
        
        let tintColor = systemColorScheme.colorForEffectsUnitState(newState)
        
        image = image?.tintedWithColor(tintColor)
        alternateImage = alternateImage?.tintedWithColor(tintColor)
    }
    
    func redraw(withTintColor tintColor: NSColor) {
        
        image = image?.tintedWithColor(tintColor)
        alternateImage = alternateImage?.tintedWithColor(tintColor)
    }
    
    func unitStateChanged(to newState: EffectsUnitState) {
        redraw(forState: newState)
    }
}
