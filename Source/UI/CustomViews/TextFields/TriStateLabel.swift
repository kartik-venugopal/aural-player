//
//  TriStateLabel.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
 An image button that can be toggled On/Off and displays different images depending on its state
 */
@IBDesignable
class OnOffLabel: CenterTextLabel {
    
    // The image displayed when the button is in an "Off" state
    var offStateColor: NSColor {
        return Colors.Effects.bypassedUnitStateColor
    }
    
    // The image displayed when the button is in an "On" state
    var onStateColor: NSColor {
        return Colors.Effects.activeUnitStateColor
    }
    
    private var _isOn: Bool = false
    
    // Sets the button state to be "Off"
    func off() {
        
        self.textColor = offStateColor
        _isOn = false
    }
    
    // Sets the button state to be "On"
    func on() {
        
        self.textColor = onStateColor
        _isOn = true
    }
    
    // Convenience function to set the button to "On" if the specified condition is true, and "Off" if not.
    func onIf(_ condition: Bool) {
        condition ? on() : off()
    }
    
    // Toggles the On/Off state
    func toggle() {
        _isOn ? off() : on()
    }
    
    // Returns true if the button is in the On state, false otherwise.
    var isOn: Bool {
        return _isOn
    }
}

/*
 A special case On/Off image button used as a bypass switch for Effects units, with preset images
 */
class FXUnitTriStateLabel: OnOffLabel {
    
    var stateFunction: (() -> FXUnitState)?
    
    var unitState: FXUnitState {
        return stateFunction?() ?? .bypassed
    }
    
    var mixedStateColor: NSColor {
        return Colors.Effects.suppressedUnitStateColor
    }
    
    func updateState() {
        
        switch unitState {
            
        case .bypassed: off()
            
        case .active: on()
            
        case .suppressed: mixed()
            
        }
    }
    
    func setUnitState(_ state: FXUnitState) {
        
        switch state {
            
        case .bypassed: off()
            
        case .active: on()
            
        case .suppressed: mixed()
            
        }
    }
    
    func mixed() {
        self.textColor = mixedStateColor
    }
    
    func reTint() {
        updateState()
    }
}

class FXUnitTriStatePreviewLabel: FXUnitTriStateLabel {
    
    override var offStateColor: NSColor {
        return Colors.Effects.defaultBypassedUnitColor
    }
    
    override var onStateColor: NSColor {
        return Colors.Effects.defaultActiveUnitColor
    }
    
    override var mixedStateColor: NSColor {
        return Colors.Effects.defaultSuppressedUnitColor
    }
}
