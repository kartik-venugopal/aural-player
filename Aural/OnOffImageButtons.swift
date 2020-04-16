import Cocoa

/*
    An image button that can be toggled On/Off and displays different images depending on its state
 */
@IBDesignable
class OnOffImageButton: NSButton {
    
    // The image displayed when the button is in an "Off" state
    @IBInspectable var offStateImage: NSImage?
    
    // The image displayed when the button is in an "On" state
    @IBInspectable var onStateImage: NSImage?
    
    // The button's tooltip when the button is in an "Off" state
    @IBInspectable var offStateTooltip: String?
    
    // The button's tooltip when the button is in an "On" state
    @IBInspectable var onStateTooltip: String?
    
    private var _isOn: Bool = false
    
    // Sets the button state to be "Off"
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
    
    // Convenience function to set the button to "On" if the specified condition is true, and "Off" if not.
    override func onIf(_ condition: Bool) {
        condition ? on() : off()
    }
    
    // Toggles the On/Off state
    override func toggle() {
        _isOn ? off() : on()
    }
    
    // Returns true if the button is in the On state, false otherwise.
    override func isOn() -> Bool {
        return _isOn
    }
}

/*
    A special case On/Off image button used as a bypass switch for Effects units, with preset images
 */
class EffectsUnitBypassButton: OnOffImageButton {
    
    override var offStateImage: NSImage? {
        
        get {
            return Images.imgSwitchOff
        }
        
        // Image should never change, so don't allow a setter
        set {}
    }
    
    override var onStateImage: NSImage? {
        
        get {
            return Images.imgSwitchOn
        }
        
        // Image should never change, so don't allow a setter
        set {}
    }
    
    override var offStateTooltip: String? {
        
        get {
            return "Activate this effects unit"
        }
        
        // Tool tip should never change, so don't allow a setter
        set {}
    }
    
    // The button's tooltip when the button is in an "On" state
    override var onStateTooltip: String? {
        
        get {
            return "Deactivate this effects unit"
        }
        
        // Tool tip should never change, so don't allow a setter
        set {}
    }
    
    // Bypass is the inverse of "On". If bypass is true, state is "Off".
    func setBypassState(_ bypass: Bool) {
        bypass ? off() : on()
    }
}

/*
 A special case On/Off image button used as a bypass switch for Effects units, with preset images
 */
class EffectsUnitTriStateBypassButton: EffectsUnitBypassButton {
    
    var stateFunction: (() -> EffectsUnitState)?
    
    var mixedStateImage: NSImage? {
        
        get {
            return Images.imgSwitchMixed
        }
        
        // Image should never change, so don't allow a setter
        set {}
    }
    
    var mixedStateTooltip: String? {
        
        get {
            return offStateTooltip
        }
        
        // Tool tip should never change, so don't allow a setter
        set {}
    }
    
    func updateState() {
        
        let newState = stateFunction!()
        
        switch newState {
            
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
        self.toolTip = mixedStateTooltip
        self.image = mixedStateImage
    }
}

@IBDesignable
class EffectsUnitTabButton: OnOffImageButton {
    
    var stateFunction: (() -> EffectsUnitState)?
    
    @IBInspectable var mixedStateImage: NSImage?
    @IBInspectable var mixedStateTooltip: String?
    
    @IBInspectable var onStateTextColor: NSColor?
    @IBInspectable var offStateTextColor: NSColor?
    @IBInspectable var mixedStateTextColor: NSColor?
    
    override func off() {
        
        super.off()
        
        if let cell = self.cell as? EffectsUnitTabButtonCell {
            cell.unitState = .bypassed
            redraw()
        }
    }
    
    override func on() {
        
        super.on()
        
        if let cell = self.cell as? EffectsUnitTabButtonCell {
            cell.unitState = .active
            redraw()
        }
    }
    
    func mixed() {
        
        self.image = mixedStateImage
        self.toolTip = mixedStateTooltip
        
        if let cell = self.cell as? EffectsUnitTabButtonCell {
            cell.unitState = .suppressed
            redraw()
        }
    }
    
    func updateState() {
        
        let newState = stateFunction!()
        
        switch newState {
            
        case .bypassed: off()
            
        case .active: on()
            
        case .suppressed: mixed()
            
        }
    }
}
