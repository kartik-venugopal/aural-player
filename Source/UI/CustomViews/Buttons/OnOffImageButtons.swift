//
//  OnOffImageButtons.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    An image button that can be toggled On/Off and displays different images depending on its state. It conforms to the current system color scheme by conforming to Tintable.
 */
@IBDesignable
class OnOffImageButton: NSButton {
    
    private var _state: NSControl.StateValue = .off
    
    var weight: NSFont.Weight = .heavy {
        
        didSet {
            image = image?.withSymbolConfiguration(.init(pointSize: 12, weight: weight))
        }
    }
    
    override var image: NSImage? {
        
        didSet {
            image?.isTemplate = true
        }
    }
    
    override var state: NSControl.StateValue {
        
        get {
            _state
        }
        
        set {
            _state = newValue
        }
    }
    
    // The button's tooltip when the button is in an "Off" state
    @IBInspectable var offStateTooltip: String?
    
    // The button's tooltip when the button is in an "On" state
    @IBInspectable var onStateTooltip: String?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        image?.isTemplate = true
    }
    
    // Sets the button state to be "Off"
    override func off() {
        
        contentTintColor = systemColorScheme.inactiveControlColor
        toolTip = offStateTooltip
        
        super.off()
    }
    
    // Sets the button state to be "On"
    override func on() {

        contentTintColor = systemColorScheme.buttonColor
        toolTip = onStateTooltip
        
        super.on()
    }

    // Convenience function to set the button to "On" if the specified condition is true, and "Off" if not.
    override func onIf(_ condition: Bool) {
        condition ? on() : off()
    }
    
    // Toggles the On/Off state
    override func toggle() {
        isOn ? off() : on()
    }
    
    func reTint() {
        isOn ? on() : off()
    }
}

// Special button used in the effects presets manager.
class EffectsUnitTriStateBypassPreviewButton: EffectsUnitTriStateBypassButton {
    
    override func awakeFromNib() {
        
//        offStateTintFunction = {Colors.Effects.defaultBypassedUnitColor}
//        onStateTintFunction = {Colors.Effects.defaultActiveUnitColor}
//        mixedStateTintFunction = {Colors.Effects.defaultSuppressedUnitColor}
    }
}
