import Cocoa

/*
    A menu item that is capable of switching (or "toggling") between two states, and displays a preset image/title corresponding to each state (example - add/remove favorites menu item)
 */
@IBDesignable
class ToggleMenuItem: NSMenuItem {
    
    // The menu item's title when it is in an "Off" state
    @IBInspectable var offStateTitle: String!
    
    // The menu item's title when it is in an "On" state
    @IBInspectable var onStateTitle: String!
    
    private var _isOn: Bool = false
    
    // Sets the item state to be "Off"
    func off() {
        self.title = offStateTitle
        _isOn = false
    }
    
    // Sets the item state to be "On"
    func on() {
        self.title = onStateTitle
        _isOn = true
    }
    
    // Convenience function to set the item to "On" if the specified condition is true, and "Off" if not.
    func onIf(_ condition: Bool) {
        condition ? on() : off()
    }
    
    // Toggles the On/Off state
    func toggle() {
        _isOn ? off() : on()
    }
    
    // Returns true if the item is in the On state, false otherwise.
    func isOn() -> Bool {
        return _isOn
    }
}
