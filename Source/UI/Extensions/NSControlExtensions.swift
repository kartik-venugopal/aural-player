import Cocoa

extension NSControl {
    
    var isDisabled: Bool {
        return !isEnabled
    }
    
    // TODO: Why not just set the flag to true/false here ???
    // Is there an overriden function somewhere in a subview ?
    @objc func enable() {
        self.enableIf(true)
    }
    
    // TODO: Why not just set the flag to true/false here ???
    // Is there an overriden function somewhere in a subview ?
    @objc func disable() {
        self.enableIf(false)
    }
    
    @objc func enableIf(_ condition: Bool) {
        self.isEnabled = condition
    }
    
    @objc func disableIf(_ condition: Bool) {
        self.isEnabled = !condition
    }
}

extension NSControl.StateValue {
 
    static let offState: NSControl.StateValue = NSControl.StateValue(rawValue: 0)
    static let onState: NSControl.StateValue = NSControl.StateValue(rawValue: 1)
}
