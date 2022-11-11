//
//  OnOffImageButtons.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    An image button that can be toggled On/Off and displays different images depending on its state. It conforms to the current system color scheme by conforming to Tintable.
 */
@IBDesignable
class OnOffImageButton: NSButton, Tintable {
    
    // The image displayed when the button is in an "Off" state
    @IBInspectable var offStateImage: NSImage? {
        
        didSet {
            
            if !_isOn {
                reTint()
            }
        }
    }
    
    // The image displayed when the button is in an "On" state
    @IBInspectable var onStateImage: NSImage? {
        
        didSet {
            
            if _isOn {
                reTint()
            }
        }
    }
    
    // The button's tooltip when the button is in an "Off" state
    @IBInspectable var offStateTooltip: String?
    
    // The button's tooltip when the button is in an "On" state
    @IBInspectable var onStateTooltip: String?
    
    // Tint to be applied when the button is in an "Off" state.
    var offStateTintFunction: () -> NSColor = {Colors.toggleButtonOffStateColor} {
        
        didSet {
            
            if !_isOn {
                reTint()
            }
        }
    }
    
    // Tint to be applied when the button is in an "On" state.
    var onStateTintFunction: () -> NSColor = {Colors.functionButtonColor} {
        
        didSet {
            
            if _isOn {
                reTint()
            }
        }
    }
    
    var _isOn: Bool = false
    
    // Sets the button state to be "Off"
    override func off() {
        
        self.image = offStateImage?.filledWithColor(offStateTintFunction())
        self.toolTip = offStateTooltip
        _isOn = false
    }
    
    // Sets the button state to be "On"
    override func on() {
        
        self.image = onStateImage?.filledWithColor(onStateTintFunction())
        self.toolTip = onStateTooltip
        _isOn = true
    }
    
    // Convenience function to set the button to "On" if the specified condition is true, and "Off" if not.
    override func onIf(_ condition: Bool) {
        condition ? on() : off()
    }
    
    // Toggles the On/Off state
    override func toggle() {
        _isOn ? off() : on()
    }
    
    // Returns true if the button is in the On state, false otherwise.
    override var isOn: Bool {
        return _isOn
    }
    
    // Re-apply the tint depending on state.
    func reTint() {
        
        if _isOn {
            self.image = onStateImage?.filledWithColor(onStateTintFunction())
        } else {
            self.image = offStateImage?.filledWithColor(offStateTintFunction())
        }
    }
}

// Special button used in the effects presets manager.
class EffectsUnitTriStateBypassPreviewButton: EffectsUnitTriStateBypassButton {
    
    override func awakeFromNib() {
        
        offStateTintFunction = {Colors.Effects.defaultBypassedUnitColor}
        onStateTintFunction = {Colors.Effects.defaultActiveUnitColor}
        mixedStateTintFunction = {Colors.Effects.defaultSuppressedUnitColor}
    }
}
