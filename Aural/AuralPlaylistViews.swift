import Cocoa

/*
    A customized NSTableView that overrides contextual menu behavior
 */
class AuralPlaylistTableView: NSTableView {
    
    // See extension below
    override func menu(for event: NSEvent) -> NSMenu? {
        return menuHandler(for: event)
    }
}

/*
    Custom view for a NSTableView row that displays a single playlist track. Customizes the selection look and feel.
 */
class AuralTableRowView: NSTableRowView {
    
    // Draws a fancy rounded rectangle around the selected track in the playlist view
    override func drawSelection(in dirtyRect: NSRect) {
        
        if self.selectionHighlightStyle != NSTableView.SelectionHighlightStyle.none {
            
            let selectionRect = self.bounds.insetBy(dx: 1, dy: 0)
            
            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 2, yRadius: 2)
            Colors.playlistSelectionBoxColor.setFill()
            selectionPath.fill()
        }
    }
}

/*
    A customized NSOutlineView that overrides contextual menu behavior
 */
class AuralPlaylistOutlineView: NSOutlineView {
    
    // See extension below
    override func menu(for event: NSEvent) -> NSMenu? {
        return menuHandler(for: event)
    }
}

// Implements an event handler for customized contextual menu behavior
extension NSTableView {
    
    /*
        This function needs to be overriden in order to:
     
        1 - Only display the contextual menu when at least one row is available, and the click occurred within a playlist row view (i.e. not in empty table view space)
        2 - Capture the row for which the contextual menu was requested, and select it
        3 - Disable the row highlight displayed when presenting the contextual menu
     */
    func menuHandler(for event: NSEvent) -> NSMenu? {
        
        // If tableView has no rows, don't show the menu
        if (self.numberOfRows == 0) {
            return nil
        }
        
        // Calculate the clicked row
        let row = self.row(at: self.convert(event.locationInWindow, from: nil))
        
        // If the click occurred outside of any of the playlist rows (i.e. empty space), don't show the menu
        if (row == -1) {
            return nil
        }
        
        // Select the clicked row, implicitly clearing the previous selection
        self.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        
        // Note that this view was clicked (this is required by the contextual menu)
        PlaylistViewContext.noteViewClicked(self)
        
        return self.menu
    }
}

/*
 Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
@IBDesignable
class TrackNameCellView: NSTableCellView {
    
    // The table view row that this cell is contained in. Used to determine whether or not this cell is selected.
    var row: Int = -1
    
    @IBInspectable @IBOutlet weak var gapBeforeImg: NSImageView!
    @IBInspectable @IBOutlet weak var gapAfterImg: NSImageView!
    
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            
            // Check if this row is selected
            let isSelRow = TableViewHolder.instance!.selectedRowIndexes.contains(row)
            
            if let textField = self.textField {
                
                textField.textColor = isSelRow ? Colors.playlistSelectedTextColor : Colors.playlistTextColor
                textField.font = isSelRow ? Fonts.playlistSelectedTextFont : Fonts.playlistTextFont
            }
        }
    }
}

/*
 Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
@IBDesignable
class DurationCellView: NSTableCellView {
    
    // The table view row that this cell is contained in. Used to determine whether or not this cell is selected.
    var row: Int = -1
    
    @IBInspectable @IBOutlet weak var gapBeforeTextField: NSTextField!
    @IBInspectable @IBOutlet weak var gapAfterTextField: NSTextField!
    
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            
            // Check if this row is selected
            let isSelRow = TableViewHolder.instance!.selectedRowIndexes.contains(row)
            
            if let textField = self.textField {
                
                textField.textColor = isSelRow ? Colors.playlistSelectedTextColor : Colors.playlistTextColor
                textField.font = isSelRow ? Fonts.playlistSelectedTextFont : Fonts.playlistTextFont
            }
            
            if let gapField = self.gapBeforeTextField {
                
                gapField.textColor = isSelRow ? Colors.playlistSelectedGapTextColor : Colors.playlistGapTextColor
                gapField.font = isSelRow ? Fonts.playlistSelectedTextFont : Fonts.playlistTextFont
            }
            
            if let gapField = self.gapAfterTextField {
                
                gapField.textColor = isSelRow ? Colors.playlistSelectedGapTextColor : Colors.playlistGapTextColor
                gapField.font = isSelRow ? Fonts.playlistSelectedTextFont : Fonts.playlistTextFont
            }
        }
    }
}

/*
 Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
@IBDesignable
class IndexCellView: NSTableCellView {
    
    // The table view row that this cell is contained in. Used to determine whether or not this cell is selected.
    var row: Int = -1
    
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            
            // Check if this row is selected
            let isSelRow = TableViewHolder.instance!.selectedRowIndexes.contains(row)
            
            if let textField = self.textField {
                
                textField.textColor = isSelRow ? Colors.playlistSelectedTextColor : Colors.playlistTextColor
                textField.font = isSelRow ? Fonts.playlistSelectedTextFont : Fonts.playlistTextFont
            }
        }
    }
}

/*
 Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
class GroupedTrackCellView: NSTableCellView {
    
    // Whether or not this cell is contained within a row that represents a group (as opposed to a track)
    var isGroup: Bool = false
    
    // This is used to determine which NSOutlineView contains this cell
    var playlistType: PlaylistType = .artists
    
    // The item represented by the row containing this cell
    var item: PlaylistItem?
    
    // When the background changes (as a result of selection/deselection) switch to the appropriate colors/fonts
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            
            // Check if this row is selected
            let outlineView = OutlineViewHolder.instances[self.playlistType]!
            let isSelRow = outlineView.selectedRowIndexes.contains(outlineView.row(forItem: item))
            
            if let textField = self.textField {
                
                textField.textColor = isSelRow ? (isGroup ? Colors.playlistGroupNameSelectedTextColor : Colors.playlistGroupItemSelectedTextColor) : (isGroup ? Colors.playlistGroupNameTextColor : Colors.playlistGroupItemTextColor)
                
                textField.font = isSelRow ? (isGroup ? Fonts.playlistGroupNameSelectedTextFont : Fonts.playlistGroupItemSelectedTextFont) : (isGroup ? Fonts.playlistGroupNameTextFont : Fonts.playlistGroupItemTextFont)
            }
        }
    }
}

@IBDesignable
class GroupedTrackNameCellView: NSTableCellView {
    
    // The table view row that this cell is contained in. Used to determine whether or not this cell is selected.
    var row: Int = -1
    
    @IBInspectable @IBOutlet weak var gapBeforeImg: NSImageView!
    @IBInspectable @IBOutlet weak var gapAfterImg: NSImageView!
    
    // Whether or not this cell is contained within a row that represents a group (as opposed to a track)
    var isGroup: Bool = false
    
    // This is used to determine which NSOutlineView contains this cell
    var playlistType: PlaylistType = .artists
    
    // The item represented by the row containing this cell
    var item: PlaylistItem?
    
    // When the background changes (as a result of selection/deselection) switch to the appropriate colors/fonts
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            
            // Check if this row is selected
            let outlineView = OutlineViewHolder.instances[self.playlistType]!
            let isSelRow = outlineView.selectedRowIndexes.contains(outlineView.row(forItem: item))
            
            if let textField = self.textField {
                
                textField.textColor = isSelRow ? (isGroup ? Colors.playlistGroupNameSelectedTextColor : Colors.playlistGroupItemSelectedTextColor) : (isGroup ? Colors.playlistGroupNameTextColor : Colors.playlistGroupItemTextColor)
                
                textField.font = isSelRow ? (isGroup ? Fonts.playlistGroupNameSelectedTextFont : Fonts.playlistGroupItemSelectedTextFont) : (isGroup ? Fonts.playlistGroupNameTextFont : Fonts.playlistGroupItemTextFont)
            }
        }
    }
}


/*
 Custom view for a NSTableView row that displays a single playlist track or group. Customizes the selection look and feel.
 */
class GroupingPlaylistRowView: NSTableRowView {
    
    // Draws a fancy rounded rectangle around the selected track in the playlist view
    override func drawSelection(in dirtyRect: NSRect) {
        
        if self.selectionHighlightStyle != NSTableView.SelectionHighlightStyle.none {
            
            let selectionRect = self.bounds.insetBy(dx: 1, dy: 0)
            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 2, yRadius: 2)
            
            Colors.playlistSelectionBoxColor.setFill()
            selectionPath.fill()
        }
    }
}

// Utility class to hold NSOutlineView instances for convenient access
class OutlineViewHolder {
    
    // Mapping of playlist types to their corresponding outline views
    static var instances = [PlaylistType: NSOutlineView]()
}
