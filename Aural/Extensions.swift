import Cocoa

extension NSButton {
    
    @objc func off() {
        self.state = UIConstants.offState
    }
    
    @objc func on() {
        self.state = UIConstants.onState
    }
    
    @objc func onIf(_ condition: Bool) {
        condition ? on() : off()
    }
    
    @objc func isOn() -> Bool {
        return self.state == UIConstants.onState
    }
    
    @objc func isOff() -> Bool {
        return self.state == UIConstants.offState
    }
    
    @objc func toggle() {
        isOn() ? off() : on()
    }
}

extension NSButtonCell {

    @objc func off() {
        self.state = UIConstants.offState
    }

    @objc func on() {
        self.state = UIConstants.onState
    }

    @objc func onIf(_ condition: Bool) {
        condition ? on() : off()
    }

    @objc func isOn() -> Bool {
        return self.state == UIConstants.onState
    }

    @objc func isOff() -> Bool {
        return self.state == UIConstants.offState
    }

    @objc func toggle() {
        isOn() ? off() : on()
    }
}

extension NSMenuItem {
    
    @objc func off() {
        self.state = UIConstants.offState
    }
    
    @objc func on() {
        self.state = UIConstants.onState
    }
    
    @objc func onIf(_ condition: Bool) {
        condition ? on() : off()
    }
    
    @objc func isOn() -> Bool {
        return self.state == UIConstants.onState
    }
    
    @objc func isOff() -> Bool {
        return self.state == UIConstants.offState
    }
    
    @objc func toggle() {
        isOn() ? off() : on()
    }
    
    var isShown: Bool {
        return !isHidden
    }
    
    func hide() {
        self.isHidden = true
    }
    
    func show() {
        self.isHidden = false
    }
    
    func hideIf_elseShow(_ condition: Bool) {
        self.isHidden = condition
    }
    
    func showIf_elseHide(_ condition: Bool) {
        self.isHidden = !condition
    }
    
    var isDisabled: Bool {
        return !isEnabled
    }
    
    func enable() {
        self.enableIf(true)
    }
    
    func disable() {
        self.enableIf(false)
    }
    
    func enableIf(_ condition: Bool) {
        self.isEnabled = condition
    }
    
    func disableIf(_ condition: Bool) {
        self.isEnabled = !condition
    }
}

extension NSView {
    
    var isShown: Bool {
        return !isHidden
    }
    
    func hide() {
        self.isHidden = true
    }
    
    func show() {
        self.isHidden = false
    }
    
    func hideIf_elseShow(_ condition: Bool) {
        self.isHidden = condition
    }
    
    func showIf_elseHide(_ condition: Bool) {
        self.isHidden = !condition
    }
    
    func hideIf(_ condition: Bool) {
        if condition {hide()}
    }

    func showIf(_ condition: Bool) {
        if condition {show()}
    }
    
    var isVisible: Bool {
        
        var curView: NSView? = self
        while curView != nil {
            
            if curView!.isHidden {return false}
            curView = curView!.superview
        }
        
        return true
    }
    
    func coLocate(_ other: NSView) {
        self.frame.origin = other.frame.origin
    }
    
    func redraw() {
        self.setNeedsDisplay(self.bounds)
    }
}

extension NSControl {
    
    var isDisabled: Bool {
        return !isEnabled
    }
    
    func enable() {
        self.enableIf(true)
    }
    
    func disable() {
        self.enableIf(false)
    }
    
    func enableIf(_ condition: Bool) {
        self.isEnabled = condition
    }
    
    func disableIf(_ condition: Bool) {
        self.isEnabled = !condition
    }
}
