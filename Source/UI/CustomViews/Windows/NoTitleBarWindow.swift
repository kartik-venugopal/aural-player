import Cocoa

class NoTitleBarWindow: NSWindow {
    
    override func awakeFromNib() {
        self.titlebarAppearsTransparent = true
    }
    
    override var canBecomeKey: Bool {true}
}

class NoTitleBarPanel: NSPanel {
    
    override func awakeFromNib() {
        self.titlebarAppearsTransparent = true
    }
}
