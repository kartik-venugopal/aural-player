import Cocoa

@IBDesignable
class TintedImageButton: NSButton, Tintable {
    
    @IBInspectable var baseImage: NSImage? {
        
        didSet {
            reTint()
        }
    }
 
    var tintFunction: () -> NSColor = {return ColorScheme.systemScheme.controlButtonColor} {
        
        didSet {
            reTint()
        }
    }
    
    func reTint() {
        self.image = self.baseImage?.applyingTint(tintFunction())
    }
}

protocol Tintable {
    
    func reTint()
}
