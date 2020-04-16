import Cocoa

/*
 An image button that can be toggled On/Off and displays different images depending on its state
 */
@IBDesignable
class OnOffImageView: NSImageView {
    
    // The image displayed when the button is in an "Off" state
    @IBInspectable var offStateImage: NSImage?
    
    // The image displayed when the button is in an "On" state
    @IBInspectable var onStateImage: NSImage?
    
    private var _isOn: Bool = false
    
    // Sets the button state to be "Off"
    func off() {
        
        self.image = offStateImage
        _isOn = false
    }
    
    // Sets the button state to be "On"
    func on() {
        
        self.image = onStateImage
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
class EffectsUnitBypassImage: OnOffImageView {
    
    // Bypass is the inverse of "On". If bypass is true, state is "Off".
    func setBypassState(_ bypass: Bool) {
        bypass ? off() : on()
    }
}

/*
 A special case On/Off image button used as a bypass switch for Effects units, with preset images
 */
class EffectsUnitTriStateBypassImage: EffectsUnitBypassImage {
    
    var stateFunction: (() -> EffectsUnitState)?
    
    @IBInspectable var mixedStateImage: NSImage?
    
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
        self.image = mixedStateImage
    }
}
