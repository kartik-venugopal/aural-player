import Cocoa

class VALabel: NSTextField {
    
    var vAlign: VAlignment = .center {
        
        didSet {
            
            (self.cell as! VALabelCell).vAlign = self.vAlign
            setNeedsDisplay(bounds)
        }
    }
    
    override func awakeFromNib() {
        
        // Hand off cell properties to the new cell
        
        let oldCell: NSTextFieldCell = self.cell as! NSTextFieldCell
        
        let textColor: NSColor = oldCell.textColor!
        let hAlign: NSTextAlignment = oldCell.alignment
        let font: NSFont = oldCell.font!

        let newCell: VALabelCell = VALabelCell(textCell: self.stringValue)
        newCell.alignment = hAlign
        newCell.vAlign = self.vAlign
        newCell.textColor = textColor
        newCell.font = font
        
        self.cell = newCell
    }
}

class VALabelCell: NSTextFieldCell {
    
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

//    NOTE - THIS FUNCTION IS FOR DEBUGGING ONLY
//    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
//
//        let rect: NSRect = self.titleRect(forBounds: cellFrame)
//        NSColor.gray.setFill()
//        rect.fill()
//
//        let r2: NSRect = self.drawingRect(forBounds: cellFrame)
//        NSColor.red.setFill()
//        r2.fill()
//
//        super.drawInterior(withFrame: cellFrame, in: controlView)
//    }
}

enum VAlignment: Int {
    
    case center = 0
    case top = 1
    case bottom = -1
}

class TopTextLabel: VALabel {

    override var vAlign: VAlignment {
        
        get {
            return .top
        }
        
        // Alignment should never change, so don't allow a setter
        set {}
    }
}

class BottomTextLabel: VALabel {
    
    override var vAlign: VAlignment {
        
        get {
            return .bottom
        }
        
        // Alignment should never change, so don't allow a setter
        set {}
    }
}

class CenterTextLabel: VALabel {
    
    override var vAlign: VAlignment {
        
        get {
            return .center
        }
        
        // Alignment should never change, so don't allow a setter
        set {}
    }
}
