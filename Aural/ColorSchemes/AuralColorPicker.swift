import Cocoa

class AuralColorPicker: NSColorWell {
    
    // Whenever this color picker's menu is invoked, this callback is invoked in turn, to let the observer know that
    // this color picker is the one that invoked the menu (this is used by the color clipboard to determine which color to copy/paste).
    var menuInvocationCallback: (AuralColorPicker) -> Void = {(AuralColorPicker) -> Void in}
    
    override func menu(for event: NSEvent) -> NSMenu? {
        
        menuInvocationCallback(self)
        return self.menu
    }
    
    func copyToClipboard(_ clipboard: ColorClipboard) {
        clipboard.copy(self.color)
    }
    
    func pasteFromClipboard(_ clipboard: ColorClipboard) {
        
        if let clipboardColor = clipboard.color {
            self.color = clipboardColor
        }
    }
}
