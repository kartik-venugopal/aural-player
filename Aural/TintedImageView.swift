import Cocoa

@IBDesignable
class TintedImageView: NSImageView, Tintable {
    
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
