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
}
