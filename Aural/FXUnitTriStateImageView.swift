import Cocoa

/*
 A special case On/Off image button used as a bypass switch for Effects units, with preset images
 */
@IBDesignable
class EffectsUnitBypassImage: NSImageView, Tintable {
    
    // The image displayed when the button is in an "Off" state
    @IBInspectable var offStateImage: NSImage?
    
    // The image displayed when the button is in an "On" state
    @IBInspectable var onStateImage: NSImage?
    
    var offStateTintFunction: () -> NSColor = {return Colors.Effects.bypassedUnitStateColor} {
        
        didSet {
            
            if !_isOn {
                reTint()
            }
        }
    }
    
    var onStateTintFunction: () -> NSColor = {return Colors.Effects.activeUnitStateColor} {
        
        didSet {
            
            if _isOn {
                reTint()
            }
        }
    }
    
    private var _isOn: Bool = false
    
    // Sets the button state to be "Off"
    func off() {
        
        self.image = offStateImage?.applyingTint(offStateTintFunction())
        _isOn = false
    }
    
    // Sets the button state to be "On"
    func on() {
        
        self.image = onStateImage?.applyingTint(onStateTintFunction())
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
        
        if _isOn {
            self.image = onStateImage?.applyingTint(onStateTintFunction())
        } else {
            self.image = offStateImage?.applyingTint(offStateTintFunction())
        }
    }
}

/*
 A special case On/Off image button used as a bypass switch for Effects units, with preset images
 */
class EffectsUnitTriStateBypassImage: EffectsUnitBypassImage {
    
    var stateFunction: (() -> EffectsUnitState)?
    
    var unitState: EffectsUnitState {
        return stateFunction?() ?? .bypassed
    }
    
    @IBInspectable var mixedStateImage: NSImage?
    
    var mixedStateTintFunction: () -> NSColor = {return Colors.Effects.suppressedUnitStateColor} {
        
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
        self.image = mixedStateImage?.applyingTint(mixedStateTintFunction())
    }
    
    override func reTint() {
        updateState()
    }
}

class EffectsUnitTriStateBypassPreviewImage: EffectsUnitTriStateBypassImage {
    
    override func awakeFromNib() {
        
        offStateTintFunction = {return Colors.Effects.defaultBypassedUnitColor}
        onStateTintFunction = {return Colors.Effects.defaultActiveUnitColor}
        mixedStateTintFunction = {return Colors.Effects.defaultSuppressedUnitColor}
    }
}
