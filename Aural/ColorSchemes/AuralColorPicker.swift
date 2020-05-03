import Cocoa

/*
    A custom color picker control that notifies observers when its context menu (i.e. right-click menu) has been invoked. This faciliates operations like copying/pasting a color from a color clipboard.
 */
class AuralColorPicker: NSColorWell {
    
    // Whenever this color picker's menu is invoked, this callback is invoked in turn, to let the observer know that
    // this color picker is the one that invoked the menu (this is used by the color clipboard to determine which color to copy/paste).
    var menuInvocationCallback: (AuralColorPicker) -> Void = {(AuralColorPicker) -> Void in}
    
    override func menu(for event: NSEvent) -> NSMenu? {
        
        // Notify the observer that the menu has been invoked.
        menuInvocationCallback(self)
        return self.menu
    }
    
    // Helper function to copy this control's color value to a color clipboard.
    func copyToClipboard(_ clipboard: ColorClipboard) {
        clipboard.copy(self.color)
    }
    
    // Helper function to paste a color clipboard's color value into this control.
    func pasteFromClipboard(_ clipboard: ColorClipboard) {
        
        if let clipboardColor = clipboard.color {
            self.color = clipboardColor
        }
    }
}
