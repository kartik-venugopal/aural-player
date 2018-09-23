import Cocoa

class ValidatedLabelCell: NSTextFieldCell {
    
    var errorState: Bool = false
    
    func markError() {
        errorState = true
        textColor = NSColor.red
    }
    
    func clearError() {
        errorState = false
        textColor = Colors.boxTextColor
    }
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        super.draw(withFrame: cellFrame, in: controlView)
        
        if errorState {
            
            let rect = NSBezierPath(rect: cellFrame)
            rect.lineWidth = 3
            
            NSColor.red.setStroke()
            rect.stroke()
        }
    }
}
