import Cocoa

class VATextField: NSTextField {
    
    var vAlign: VAlignment = .center {
        
        didSet {
            
            (self.cell as! VATextFieldCell).vAlign = self.vAlign
            setNeedsDisplay(bounds)
        }
    }
}

class VATextFieldCell: NSTextFieldCell {
    
    var vAlign: VAlignment = .center
    
    override func drawingRect(forBounds theRect: NSRect) -> NSRect {
        
        var newRect: NSRect = super.drawingRect(forBounds: theRect)
        let textSize: NSSize = self.cellSize(forBounds: theRect)
        
        let heightDelta: CGFloat = newRect.size.height - textSize.height
        
        if heightDelta > 0 {
            newRect.size.height -= heightDelta
        }
        
        switch self.vAlign {
            
        case .center:   newRect.origin.y += heightDelta / 2
            
        case .top:      newRect.origin.y = 0
            
        case .bottom:   newRect.origin.y += heightDelta
            
        }
        
        return newRect
    }
}

enum VAlignment: Int {
    
    case center = 0
    case top = 1
    case bottom = -1
}

