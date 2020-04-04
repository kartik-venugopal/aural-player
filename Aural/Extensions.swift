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
    
    @objc func displaceLeft(_ amount: CGFloat) {
        self.frame.origin.x -= amount
    }

    @objc func displaceRight(_ amount: CGFloat) {
        self.frame.origin.x += amount
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
    
    func addSubviews(_ subViews: NSView...) {
        subViews.forEach({self.addSubview($0)})
    }
    
    func positionAtZeroPoint() {
        self.setFrameOrigin(NSPoint.zero)
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

extension NSPopUpButton {
    
    var separatorCount: Int {
        
        var count: Int = 0
        
        for item in self.menu!.items {
            if item.isSeparatorItem {count += 1}
        }
        
        return count
    }
}

class NoTitleBarWindow: NSWindow {
    
    override func awakeFromNib() {
        self.titlebarAppearsTransparent = true
    }
    
    override var canBecomeKey: Bool {
        get {return true}
    }
}

class NoTitleBarPanel: NSPanel {
    
    override func awakeFromNib() {
        self.titlebarAppearsTransparent = true
    }
}

extension NSTabView {
    
    var selectedIndex: Int {
        return indexOfTabViewItem(selectedTabViewItem!)
    }
    
    func previousTab(_ sender: Any) {
        
        let selIndex = selectedIndex
        
        if selIndex >= 1 {
            selectPreviousTabViewItem(sender)
        } else {
            selectLastTabViewItem(sender)
        }
    }
    
    func nextTab(_ sender: Any) {
        
        let selIndex = selectedIndex
        
        if selIndex < tabViewItems.count - 1 {
            selectNextTabViewItem(sender)
        } else {
            selectFirstTabViewItem(sender)
        }
    }
}

extension String {
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + (self.count > 1 ? self.substring(range: 1..<self.count) : "")
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
