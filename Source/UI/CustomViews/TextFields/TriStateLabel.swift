//
//  TriStateLabel.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
 An image button that can be toggled On/Off and displays different images depending on its state
 */
@IBDesignable
class EffectsUnitTriStateLabel: CenterTextLabel, TextualFXUnitStateObserver {
    
    private var state: NSControl.StateValue = .off
    
    // Sets the button state to be "Off"
    func off() {
        state = .off
    }
    
    // Sets the button state to be "On"
    func on() {
        state = .on
    }
    
    func mixed() {
        state = .off
    }
    
    // Convenience function to set the button to "On" if the specified condition is true, and "Off" if not.
    func onIf(_ condition: Bool) {
        condition ? on() : off()
    }
    
    // Toggles the On/Off state
    func toggle() {
        isOn ? off() : on()
    }
    
    // Returns true if the button is in the On state, false otherwise.
    var isOn: Bool {state == .on}
}

class EffectsUnitTriStatePreviewLabel: EffectsUnitTriStateLabel {
    
//    override var offStateColor: NSColor {Colors.Effects.defaultBypassedUnitColor}
//
//    override var onStateColor: NSColor {Colors.Effects.defaultActiveUnitColor}
//
//    override var mixedStateColor: NSColor {Colors.Effects.defaultSuppressedUnitColor}
}
