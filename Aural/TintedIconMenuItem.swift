import Cocoa

@IBDesignable
class TintedIconMenuItem: NSMenuItem, Tintable {
    
    @IBInspectable var baseImage: NSImage? {
        
        didSet {
            reTint()
        }
    }
    
    var tintFunction: () -> NSColor = {return Colors.viewControlButtonColor} {
        
        didSet {
            reTint()
        }
    }
    
    func reTint() {
        self.image = self.baseImage?.applyingTint(tintFunction())
    }
}
