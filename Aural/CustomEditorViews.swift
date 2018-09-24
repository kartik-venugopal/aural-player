import Cocoa

class AuralTableHeaderCell: NSTableHeaderCell {
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let attrs: [String: AnyObject] = [
            NSFontAttributeName: Fonts.editorHeaderTextFont,
            NSForegroundColorAttributeName: Colors.editorHeaderTextColor]
        
        stringValue.draw(in: cellFrame.insetBy(dx: 5, dy: 0), withAttributes: attrs)
        
        // Bottom line
        let drawRect = cellFrame.insetBy(dx: 0, dy: 16).offsetBy(dx: 0, dy: 10)
        let roundedPath = NSBezierPath.init(rect: drawRect)
        
        let lineColor = NSColor(calibratedWhite: 0.3, alpha: 1)
        lineColor.setFill()
        roundedPath.fill()
        
        // Right Partition line
        let cw = cellFrame.width
        let pline = cellFrame.insetBy(dx: cw / 2 - 1.5, dy: 5).offsetBy(dx: cw / 2 - 3, dy: -3)
        
        let path = NSBezierPath.init(rect: pline)
        lineColor.setFill()
        path.fill()
    }
}

/*
 Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
class EditorTableCellView: NSTableCellView {
    
    // The table view row that this cell is contained in. Used to determine whether or not this cell is selected.
    var row: Int = -1
    
    var isSelectedFunction: ((Int) -> Bool)?
    
    // When the background changes (as a result of selection/deselection) switch to the appropriate colors/fonts
    override var backgroundStyle: NSBackgroundStyle {
        
        didSet {
            
            // Check if this row is selected
            let isSelRow = isSelectedFunction!(row)
            
            if let textField = self.textField {
                
                textField.textColor = isSelRow ? Colors.playlistSelectedTextColor : Colors.playlistTextColor
                textField.font = isSelRow ? Fonts.playlistSelectedTextFont : Fonts.playlistTextFont
            }
        }
    }
}

// Used to change text field selection cursor and text color
class EditorTextField: NSTextField {
    
    override func becomeFirstResponder() -> Bool {
        
        self.textColor = NSColor.black
        
        // Cursor color
        let fieldEditor = self.window!.fieldEditor(true, for: self) as! NSTextView
        fieldEditor.insertionPointColor = NSColor.black
        
        return super.becomeFirstResponder()
    }
}
