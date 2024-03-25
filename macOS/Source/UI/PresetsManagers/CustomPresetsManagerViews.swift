//
//  CustomPresetsManagerViews.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class PresetsManagerTableHeaderCell: NSTableHeaderCell {
    
    private static let lineColor = NSColor.white30Percent
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        stringValue.draw(in: cellFrame.insetBy(dx: 5, dy: 3), withFont: .presetsManagerTableHeaderTextFont,
                         andColor: .presetsManagerTableHeaderTextColor)

        // Right Partition line
        let cw = cellFrame.width
        let pline = cellFrame.insetBy(dx: cw / 2 - 0.5, dy: 5).offsetBy(dx: cw / 2 - 3, dy: -3)
        
        let path = NSBezierPath.init(rect: pline)
        path.fill(withColor: Self.lineColor)
    }
}

/*
    Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
class PresetsManagerTableCellView: NSTableCellView {
    
    // The table view row that this cell is contained in. Used to determine whether or not this cell is selected.
    var row: Int = -1
    
    var isSelectedFunction: ((Int) -> Bool) = {row in false}
    
    // When the background changes (as a result of selection/deselection) switch to the appropriate colors/fonts
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            
            // Check if this row is selected
            let isSelRow = isSelectedFunction(row)
            
            if let textField = self.textField {
                
                textField.textColor = isSelRow ? .defaultSelectedLightTextColor : .defaultLightTextColor
                textField.font = isSelRow ? .presetsManagerTableSelectedTextFont : .presetsManagerTableTextFont
            }
        }
    }
}

// Used to change text field selection cursor and text color
class EditableTextField: NSTextField {
    
    var editTextColor: PlatformColor {
        systemColorScheme.primarySelectedTextColor
    }
    
    var editCursorColor: PlatformColor {
        systemColorScheme.primarySelectedTextColor
    }
    
    private var origTextColor: NSColor!
    
    override func becomeFirstResponder() -> Bool {

        origTextColor = self.textColor
        self.textColor = editTextColor
        
        // Cursor color
        let fieldEditor = self.window!.fieldEditor(true, for: self) as! NSTextView
        fieldEditor.insertionPointColor = editCursorColor
        
        return super.becomeFirstResponder()
    }
    
    func restoreTextColor() {
        
        if let origTextColor = self.origTextColor {
            self.textColor = origTextColor
        }
    }
}

class EditableLibraryTextField: EditableTextField {
    
    override var editTextColor: PlatformColor {
        systemColorScheme.primaryTextColor
    }
    
    override var editCursorColor: PlatformColor {
        systemColorScheme.primaryTextColor
    }
}
