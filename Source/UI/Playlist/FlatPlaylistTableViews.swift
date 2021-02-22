import Cocoa

extension NSView {
    
    func activateAndAddConstraint(_ constraint: NSLayoutConstraint) {
        
        constraint.isActive = true
        self.addConstraint(constraint)
    }
    
    func deactivateAndRemoveConstraint(_ constraint: NSLayoutConstraint) {
        
        constraint.isActive = false
        self.removeConstraint(constraint)
    }
}

/*
    A customized NSTableView that overrides contextual menu behavior
 */
class AuralPlaylistTableView: NSTableView {
    
    override func menu(for event: NSEvent) -> NSMenu? {
        return menuHandler(for: event)
    }
}

/*
    Custom view for a NSTableView row that displays a single playlist track or group. Customizes the selection look and feel.
 */
class PlaylistRowView: NSTableRowView {
    
    // Draws a fancy rounded rectangle around the selected track in the playlist view
    override func drawSelection(in dirtyRect: NSRect) {
        
        if self.selectionHighlightStyle != .none {
            
            let selectionRect = self.bounds.insetBy(dx: 1, dy: 0)
            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 2, yRadius: 2)
            
            Colors.Playlist.selectionBoxColor.setFill()
            selectionPath.fill()
        }
    }
}

class BasicFlatPlaylistCellView: NSTableCellView {
    
    // Used to determine whether or not this cell is selected.
    var rowSelectionStateFunction: () -> Bool = {false}
    
    var rowIsSelected: Bool {rowSelectionStateFunction()}
    
    func updateText(_ font: NSFont, _ text: String) {
        
        textField?.font = font
        textField?.stringValue = text
        textField?.show()
        
        imageView?.hide()
    }
    
    func updateImage(_ image: NSImage) {
        
        imageView?.image = image
        imageView?.show()
        
        textField?.hide()
    }

    // Constraints
    func realignText(yOffset: CGFloat) {
        
        guard let textField = self.textField else {return}
        
        // Remove any existing constraints on the text field's 'bottom' attribute
        self.constraints.filter {$0.firstItem === textField && $0.firstAttribute == .bottom}.forEach {self.deactivateAndRemoveConstraint($0)}

        let textFieldBottomConstraint = NSLayoutConstraint(item: textField, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: yOffset)
        
        self.activateAndAddConstraint(textFieldBottomConstraint)
    }
    
    override var backgroundStyle: NSView.BackgroundStyle {
        didSet {backgroundStyleChanged()}
    }

    // Check if this row is selected, change font and color accordingly
    func backgroundStyleChanged() {
        
        textField?.textColor = rowIsSelected ? Colors.Playlist.trackNameSelectedTextColor : Colors.Playlist.trackNameTextColor
        textField?.font = FontSets.systemFontSet.playlist.trackTextFont
    }
}

/*
    Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
@IBDesignable
class TrackNameCellView: BasicFlatPlaylistCellView {

}

/*
    Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
@IBDesignable
class DurationCellView: BasicFlatPlaylistCellView {
    
    override func backgroundStyleChanged() {
        
        let isSelectedRow = rowIsSelected
        
        // Check if this row is selected, change font and color accordingly
        textField?.textColor = isSelectedRow ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
        textField?.font = FontSets.systemFontSet.playlist.trackTextFont
    }
}

/*
    Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
class IndexCellView: BasicFlatPlaylistCellView {
    
    override func backgroundStyleChanged() {
        
        // Check if this row is selected, change font and color accordingly
        textField?.textColor = rowIsSelected ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
        textField?.font = FontSets.systemFontSet.playlist.trackTextFont
    }
}
