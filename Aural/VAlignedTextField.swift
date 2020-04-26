import Cocoa

class VALabel: NSTextField {
    
    var debug: Bool = false
    
    var vAlign: VAlignment = .center {
        
        didSet {
            
            (self.cell as! VALabelCell).vAlign = self.vAlign
            setNeedsDisplay(bounds)
        }
    }
    
    override func awakeFromNib() {
        
        // Hand off cell properties to the new cell
        
        if let cell = self.cell as? VALabelCell {
            cell.vAlign = self.vAlign
            cell.debug = self.debug
            return
        }
        
        let oldCell: NSTextFieldCell = self.cell as! NSTextFieldCell
        
        if !(oldCell is VALabelCell) {
            
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
}

class VALabelCell: NSTextFieldCell {
    
    var debug: Bool = false
    
    var vAlign: VAlignment = .center
    
    override func drawingRect(forBounds theRect: NSRect) -> NSRect {
        
        var newRect: NSRect = super.drawingRect(forBounds: theRect)
        let textSize: NSSize = self.cellSize(forBounds: theRect)
        
        if self.stringValue == "Master" {

            let s2 = StringUtils.sizeOfString(self.stringValue, self.font!)
            print("\nRect:", newRect, "TS:", textSize, "S2:", s2)
        }
        
        let heightDelta: CGFloat = newRect.size.height - textSize.height
        
        if heightDelta > 0 {
            newRect.size.height -= heightDelta
        }
        
//        if self.stringValue == "Master" {
//            print("HDelta:", heightDelta)
//        }
//
        switch self.vAlign {
            
        case .center:   newRect.origin.y += heightDelta / 2
            
        case .top:      newRect.origin.y = 0
            
        case .bottom:   newRect.origin.y += heightDelta
            
        }
        
        // HACK
        if self.font?.familyName?.contains("Alegreya") ?? false {
            newRect.origin.y -= 2
        }
//
        if self.stringValue == "Master" {
        print("NOW Rect:", newRect)
        }
//
        return newRect
    }

//    NOTE - THIS FUNCTION IS FOR DEBUGGING ONLY
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        if debug {
            
            let rect: NSRect = self.titleRect(forBounds: cellFrame)
            NSColor.gray.setFill()
            rect.fill()
            
            let r2: NSRect = self.drawingRect(forBounds: cellFrame)
            NSColor.red.setFill()
            r2.fill()
            
            var drawPath = NSBezierPath.init(rect: rect)
            NSColor.yellow.setStroke()
            drawPath.stroke()
            
            let halfRect: NSRect = NSRect(x: rect.origin.x, y: rect.origin.y, width: rect.width, height: rect.height / 2)
            drawPath = NSBezierPath.init(rect: halfRect)
            NSColor.green.setStroke()
            drawPath.stroke()
        }

        super.drawInterior(withFrame: cellFrame, in: controlView)
    }
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

class FXUnitCaptionCell: VALabelCell {

    override func drawingRect(forBounds theRect: NSRect) -> NSRect {

        switch EffectsViewState.textSize {

        case .normal:

            return NSRect(origin: NSMakePoint(0, theRect.height - 23), size: NSMakeSize(theRect.width, 23))
            
        case .larger:
            
            return NSRect(origin: NSMakePoint(0, theRect.height - 25 + 1), size: NSMakeSize(theRect.width, 25))
            
        case .largest:
            
            return NSRect(origin: NSMakePoint(0, theRect.height - 29 + 2), size: NSMakeSize(theRect.width, 29))
        }
    }
}
