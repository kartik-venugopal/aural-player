import Cocoa

class AuralTableHeaderCell: NSTableHeaderCell {
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let attrs: [String: AnyObject] = [
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): Fonts.editorTableHeaderTextFont,
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): Colors.editorHeaderTextColor]
        
        stringValue.draw(in: cellFrame.insetBy(dx: 5, dy: 3), withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attrs))

        // Right Partition line
        let lineColor = Colors.Constants.white30Percent
        let cw = cellFrame.width
        let pline = cellFrame.insetBy(dx: cw / 2 - 0.5, dy: 5).offsetBy(dx: cw / 2 - 3, dy: -3)
        
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
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            
            // Check if this row is selected
            let isSelRow = isSelectedFunction!(row)
            
            if let textField = self.textField {
                
                textField.textColor = isSelRow ? Colors.defaultSelectedLightTextColor : Colors.defaultLightTextColor
                textField.font = isSelRow ? Fonts.editorTableSelectedTextFont : Fonts.editorTableTextFont
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
