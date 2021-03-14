import Cocoa

class PrettyScroller: NSScroller {
    
    let barRadius: CGFloat = 0.75
    let barInsetX: CGFloat = 7
    let barInsetY: CGFloat = 0
    
    let knobInsetX: CGFloat = 5
    let knobInsetY: CGFloat = 0
    let knobRadius: CGFloat = 1

    var knobColor: NSColor = NSColor.gray
    
    override func awakeFromNib() {
        self.scrollerStyle = .overlay
    }
    
    override func drawKnob() {
        
        let knobRect = self.rect(for: .knob).insetBy(dx: knobInsetX, dy: knobInsetY)
        
        if knobRect.height <= 0 || knobRect.width <= 0 {return}
        
        let drawPath = NSBezierPath.init(roundedRect: knobRect, xRadius: knobRadius, yRadius: knobRadius)
        
        Colors.scrollerKnobColor.setFill()
        drawPath.fill()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        let rect = dirtyRect.insetBy(dx: barInsetX, dy: barInsetY)
        let drawPath = NSBezierPath.init(roundedRect: rect, xRadius: barRadius, yRadius: barRadius)
        
        Colors.scrollerBarColor.setFill()
        drawPath.fill()
        
        self.drawKnob()
    }
}
