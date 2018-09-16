import Cocoa

@IBDesignable
class BannerLabel: NSView {
    
    private var viewLoaded: Bool = false {
        
        didSet {
            
            label?.stringValue = text
            if viewLoaded {
                textChanged()
            }
        }
    }
    
    @IBInspectable var text: String! = "" {
        
        didSet {
            
            label?.stringValue = text
            if viewLoaded {
                textChanged()
            }
        }
    }
    
    var textWidth: CGFloat! = 0
    
    var font: NSFont! {
        
        didSet {
            label?.font = font
        }
    }
    
    @IBInspectable var textColor: NSColor! {
        
        didSet {
            label?.textColor = textColor
        }
    }
    
    @IBInspectable var backgroundColor: NSColor! {
        
        didSet {
            label?.backgroundColor = backgroundColor
        }
    }
    
    var alignment: NSTextAlignment! {
        
        didSet {
            label?.alignment = alignment
        }
    }
    
    private var label: NSTextField!
    
    override func awakeFromNib() {
        
        label = NSTextField.createLabel(self.text, self.font, self.alignment, self.textColor, self.backgroundColor)
        
        self.addSubview(label)
        label.setFrameSize(self.frame.size)
        label.setFrameOrigin(NSPoint.zero)
        
        self.wantsLayer = true
        viewLoaded = true
    }
    
    private func textChanged() {
        
//        NSLog("Text changed to: %@ %@", text, String(describing: self.layer))
        
//        self.layer?.removeAllAnimations()
//        self.layer?.presentation()?.removeAllAnimations()
        label.setFrameOrigin(NSPoint.zero)
        
        if self.font != nil {
        
            let size: CGSize = (self.text as NSString).size(withAttributes: [NSFontAttributeName: label.font!])
            textWidth = size.width
            
            label?.setFrameSize(NSSize(width: max(textWidth + 10, self.frame.width), height: label.frame.height))
            
            if textWidth >= self.frame.width && self.viewLoaded {
                doBeginAnimation(self.text)
            }
        }
    }
    
    private func doBeginAnimation(_ animatedText: String) {
        
//        Swift.print("\n")
//        NSLog("Begin anim %@ %.0f", text, textWidth)
        
        let distanceToMove = self.frame.width - label.frame.width
        
//        NSLog("Dist=%f", distanceToMove)
        
        NSAnimationContext.runAnimationGroup({_ in
//            
            // Duration at least 2 seconds
            let dur = max(Double(abs(distanceToMove)) / 30, 2)
//            NSLog("Dur=%lf", dur)
            
            NSAnimationContext.current().duration = dur
            
            NSAnimationContext.current().timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            // Move either left or right (alternate, creating a ping-pong effect)
            let xDest = label.frame.origin.x == 0 ? distanceToMove: 0
            label.animator().setFrameOrigin(NSPoint(x: xDest, y: 0))
            
//            NSLog("\tRunning anim %@ %.0f", text, textWidth)
            
        }, completionHandler: {
            
//            Swift.print("Anim ended:", animatedText)
    
            if animatedText == self.text && self.viewLoaded {
                
                // Loop indefinitely
//                NSLog("\tRestarting anim %@ %.0f", self.text, self.textWidth)
                self.doBeginAnimation(animatedText)
            }
        })
    }
    
    func beginAnimation() {
        viewLoaded = true
    }
    
    func endAnimation() {
        viewLoaded = false
    }
}

extension NSTextField {
    
    static func createLabel(_ string: String!, _ font: NSFont!, _ alignment: NSTextAlignment!, _ textColor: NSColor!, _ backgroundColor: NSColor!) -> NSTextField {
        
        let label = NSTextField()
        
        label.stringValue = string
        label.isSelectable = false
        label.isEditable = false
        
        label.font = font
        if (alignment != nil) {
            label.alignment = alignment
        }
        label.textColor = textColor
        label.backgroundColor = backgroundColor
        
        label.drawsBackground = true
        label.isBordered = false
        
        return label
    }
}
