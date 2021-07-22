//
//  EffectsUnitTriStateBypassImage.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    A special case On/Off image button used as a bypass switch for effects units, with preset images
 */
@IBDesignable
class EffectsUnitTriStateBypassImage: NSImageView, Tintable {
    
    var stateFunction: EffectsUnitStateFunction?
    
    var unitState: EffectsUnitState {
        stateFunction?() ?? .bypassed
    }
    
    var offStateTintFunction: () -> NSColor = {Colors.Effects.bypassedUnitStateColor} {
        
        didSet {
            
            if !_isOn {
                reTint()
            }
        }
    }
    
    var onStateTintFunction: () -> NSColor = {Colors.Effects.activeUnitStateColor} {
        
        didSet {
            
            if _isOn {
                reTint()
            }
        }
    }
    
    var mixedStateTintFunction: () -> NSColor = {Colors.Effects.suppressedUnitStateColor} {
        
        didSet {
            
            if unitState == .suppressed {
                reTint()
            }
        }
    }
    
    func updateState() {
        
        switch unitState {
            
        case .bypassed: off()
            
        case .active: on()
            
        case .suppressed: mixed()
            
        }
    }
    
    func setUnitState(_ state: EffectsUnitState) {
        
        switch state {
            
        case .bypassed: off()
            
        case .active: on()
            
        case .suppressed: mixed()
            
        }
    }
    
    func mixed() {
        self.image = self.image?.filledWithColor(mixedStateTintFunction())
    }
    
    private var _isOn: Bool = false
    
    // Sets the button state to be "Off"
    func off() {
        
        self.image = self.image?.filledWithColor(offStateTintFunction())
        _isOn = false
    }
    
    // Sets the button state to be "On"
    func on() {
        
        self.image = self.image?.filledWithColor(onStateTintFunction())
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
    
    // Bypass is the inverse of "On". If bypass is true, state is "Off".
    func setBypassState(_ bypass: Bool) {
        bypass ? off() : on()
    }
    
    func reTint() {
        updateState()
    }
}

class EffectsUnitTriStateBypassPreviewImage: EffectsUnitTriStateBypassImage {
    
    override func awakeFromNib() {
        
        offStateTintFunction = {Colors.Effects.defaultBypassedUnitColor}
        onStateTintFunction = {Colors.Effects.defaultActiveUnitColor}
        mixedStateTintFunction = {Colors.Effects.defaultSuppressedUnitColor}
    }
}
