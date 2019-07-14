import Cocoa

/*
 An image button that can be toggled On/Off and displays different images depending on its state
 */
@IBDesignable
class OnOffLabel: CenterTextLabel {
    
    // The image displayed when the button is in an "Off" state
    @IBInspectable var offStateColor: NSColor?
    
    // The image displayed when the button is in an "On" state
    @IBInspectable var onStateColor: NSColor?
    
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
    func isOn() -> Bool {
        return _isOn
    }
}

/*
 A special case On/Off image button used as a bypass switch for Effects units, with preset images
 */
class EffectsUnitTriStateLabel: OnOffLabel {
    
    var stateFunction: (() -> EffectsUnitState)?
    
    @IBInspectable var mixedStateColor: NSColor?
    
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
        self.textColor = mixedStateColor
    }
    
    func colorSchemeChanged() {
        
        switch stateFunction!() {
            
        case .bypassed: off()
            
        case .active: on()
            
        case .suppressed: mixed()
            
        }
    }
}
