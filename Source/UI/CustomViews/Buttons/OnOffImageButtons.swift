//
//  OnOffImageButtons.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    A special on/off image button whose images do not change.
 */
class RecorderToggleButton: OnOffImageButton {
    
    override func off() {
        
        self.image = offStateImage
        self.toolTip = offStateTooltip
        _isOn = false
    }
    
    // Sets the button state to be "On"
    override func on() {
        
        self.image = onStateImage
        self.toolTip = onStateTooltip
        _isOn = true
    }
    
    override func reTint() {
        // Do nothing
    }
}

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
    var offStateTintFunction: () -> NSColor = {return Colors.toggleButtonOffStateColor} {
        
        didSet {
            
            if !_isOn {
                reTint()
            }
        }
    }
    
    // Tint to be applied when the button is in an "On" state.
    var onStateTintFunction: () -> NSColor = {return Colors.functionButtonColor} {
        
        didSet {
            
            if _isOn {
                reTint()
            }
        }
    }
    
    fileprivate var _isOn: Bool = false
    
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

/*
 A special case On/Off image button used as a bypass switch for effects units, with preset images
 */
class EffectsUnitTriStateBypassButton: OnOffImageButton {
    
    var stateFunction: (() -> EffectsUnitState)?
    
    var unitState: EffectsUnitState {
        return stateFunction?() ?? .bypassed
    }
    
    var mixedStateTooltip: String?
    
    // Tint to be applied when the button is in a "mixed" state (eg. when an effects unit is suppressed).
    var mixedStateTintFunction: () -> NSColor = {return Colors.Effects.suppressedUnitStateColor} {
        
        didSet {
            
            if unitState == .suppressed {
                reTint()
            }
        }
    }
    
    override func awakeFromNib() {
        
        self.image = Images.imgSwitch
        
        // Override the tint functions from OnOffImageButton
        offStateTintFunction = {return Colors.Effects.bypassedUnitStateColor}
        onStateTintFunction = {return Colors.Effects.activeUnitStateColor}
        
        offStateTooltip = offStateTooltip ?? "Activate this effects unit"
        onStateTooltip = onStateTooltip ?? "Deactivate this effects unit"
        mixedStateTooltip = offStateTooltip
    }
    
    // Bypass is the inverse of "On". If bypass is true, state is "Off".
    func setBypassState(_ bypass: Bool) {
        bypass ? off() : on()
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
    
    // Sets the button state to be "Off"
    override func off() {
        
        self.image = self.image?.filledWithColor(offStateTintFunction())
        self.toolTip = offStateTooltip
        _isOn = false
    }
    
    // Sets the button state to be "On"
    override func on() {
        
        self.image = self.image?.filledWithColor(onStateTintFunction())
        self.toolTip = onStateTooltip
        _isOn = true
    }
    
    func mixed() {
        
        self.image = self.image?.filledWithColor(mixedStateTintFunction())
        self.toolTip = mixedStateTooltip
    }
    
    override func reTint() {
        updateState()
    }
}

@IBDesignable
class EffectsUnitTabButton: OnOffImageButton {
    
    var stateFunction: (() -> EffectsUnitState)?
    
    @IBInspectable var mixedStateTooltip: String?
    
    var mixedStateTintFunction: () -> NSColor = {return Colors.Effects.suppressedUnitStateColor} {
        
        didSet {
            reTint()
        }
    }
    
    override func awakeFromNib() {
        
        // Override the tint functions from OnOffImageButton
        offStateTintFunction = {return Colors.Effects.bypassedUnitStateColor}
        onStateTintFunction = {return Colors.Effects.activeUnitStateColor}
    }
    
    override func off() {
        
        self.image = self.image?.filledWithColor(offStateTintFunction())
        self.toolTip = offStateTooltip
        _isOn = false
        
        if let cell = self.cell as? EffectsUnitTabButtonCell {
            cell.unitState = .bypassed
            redraw()
        }
    }
    
    override func on() {
        
        self.image = self.image?.filledWithColor(onStateTintFunction())
        self.toolTip = onStateTooltip
        _isOn = true
        
        if let cell = self.cell as? EffectsUnitTabButtonCell {
            cell.unitState = .active
            redraw()
        }
    }
    
    func mixed() {
        
        self.image = self.image?.filledWithColor(mixedStateTintFunction())
        self.toolTip = mixedStateTooltip
        
        if let cell = self.cell as? EffectsUnitTabButtonCell {
            cell.unitState = .suppressed
            redraw()
        }
    }
    
    override func reTint() {
        
        switch unitState {
            
        case .bypassed: self.image = self.image?.filledWithColor(offStateTintFunction())
            
        case .active: self.image = self.image?.filledWithColor(onStateTintFunction())
            
        case .suppressed: self.image = self.image?.filledWithColor(mixedStateTintFunction())
            
        }
        
        // Need to redraw because we are using a custom button cell which needs to render the updated image itself
        redraw()
    }
    
    func updateState() {
        
        let newState = stateFunction!()
        
        switch newState {
            
        case .bypassed: off()
            
        case .active: on()
            
        case .suppressed: mixed()
            
        }
    }
    
    var unitState: EffectsUnitState {
        return stateFunction?() ?? .bypassed
    }
}

// Special button used in the effects presets manager.
class EffectsUnitTriStateBypassPreviewButton: EffectsUnitTriStateBypassButton {
    
    override func awakeFromNib() {
        
        offStateTintFunction = {return Colors.Effects.defaultBypassedUnitColor}
        onStateTintFunction = {return Colors.Effects.defaultActiveUnitColor}
        mixedStateTintFunction = {return Colors.Effects.defaultSuppressedUnitColor}
    }
}
